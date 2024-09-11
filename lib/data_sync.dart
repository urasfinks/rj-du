import 'dart:async';
import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:http/http.dart';
import 'package:rjdu/dynamic_invoke/handler/controller_handler.dart';
import 'package:rjdu/dynamic_invoke/handler_custom/custom_loader_close_handler.dart';
import 'package:rjdu/navigator_app.dart';
import 'package:rjdu/storage.dart';
import 'data_type.dart';
import 'db/data_source.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'dynamic_invoke/handler_custom/custom_loader_open_handler.dart';
import 'global_settings.dart';
import 'http_client.dart';
import 'system_notify.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'db/data.dart';
import 'db/data_getter.dart';
import "dart:collection";

/*
* Если у данных ревизия = 0 - это значит, что данные не синхронизованны с внешней БД
* Синхронизация доступна только для типов данных заканчивающихсяна на RSync (Remote Synchronization)
* В текущий момент это тип: userDataRSync/blobRSync
* + socket, причём в неавтаризованной синхронизации!
*
* Возможные сценарии установки значений для revision:
* [0] При вставке по умолчанию
* [0] При обновлении если устаноавлен флаг updateIfExist = true и тип данных заканчивается на RSync
* [~] При вставке/обновлении с предзаполненным revision
*
* Для сокетных данных - сервер является мастер системой. На локали ревизии для сокетных данных не обновляются
* */

class SyncResult {
  int countUpgrade;
  bool _error = false;
  String? cause;

  SyncResult(this.countUpgrade);

  setError(String cause) {
    this.cause = cause;
    _error = true;
  }

  bool isSuccess() {
    return !_error;
  }

  @override
  String toString() {
    return 'SyncResult{countUpgrade: $countUpgrade, _error: $_error, cause: $cause}';
  }
}

class TaskSync {
  Function(SyncResult syncResult)? callback;
  List<String> lazy = [];

  TaskSync(List<String>? lazy, this.callback) {
    if (lazy != null && lazy.isNotEmpty) {
      this.lazy.addAll(lazy);
    }
  }
}

class DataSync {
  static final DataSync _singleton = DataSync._internal();

  factory DataSync() {
    return _singleton;
  }

  DataSync._internal();

  Cron? cron;
  bool appIsActive = true;
  final Queue<TaskSync> taskQueue = Queue<TaskSync>();
  String? lastTemplate;

  void restart(String template) async {
    if (lastTemplate == template) {
      return;
    }
    lastTemplate = template;
    try {
      if (cron != null) {
        await cron!.close();
      }
      cron = Cron();
      cron!.schedule(Schedule.parse(template), sync);
      sync();
    } catch (e, stacktrace) {
      Util.printStackTrace("DataSync.restart() template: $template", e, stacktrace);
    }
  }

  void openLoader() {
    if (NavigatorApp.getLast() != null) {
      DynamicInvoke().sysInvokeType(CustomLoaderOpenHandler, {}, NavigatorApp.getLast()!.dynamicUIBuilderContext);
    }
  }

  bool getAuthJustNow() {
    bool authJustNow = Storage().get("authJustNow", "false") == "true";
    if (authJustNow) {
      Storage().set("authJustNow", "false");
    }
    return authJustNow;
  }

  void updateLoaderStatus(Map<String, dynamic> parseJson, int firstTotalCountItem) {
    try {
      int curTotalCountItem = parseJson["totalCountItem"];
      DynamicInvoke().sysInvokeType(
        ControllerHandler,
        {
          "controller": "loader",
          "data": {"prc": ((firstTotalCountItem - curTotalCountItem) * 100 / firstTotalCountItem).ceil()}
        },
        NavigatorApp.getLast()!.dynamicUIBuilderContext,
      );
    } catch (error, stackTrace) {
      Util.printStackTrace("DataSync.updateLoaderStatus()", error, stackTrace);
    }
  }

  int parseUpgradeData(Map<String, dynamic> parseJson, Map<String, int> maxRevisionByType) {
    int countUpgrade = 0;
    if (parseJson["upgrade"] != null) {
      for (MapEntry<String, dynamic> item in parseJson["upgrade"].entries) {
        DataType dataType = Util.dataTypeValueOf(item.key);
        for (Map<String, dynamic> curData in item.value) {
          Data? updData = upgradeData(curData, dataType, maxRevisionByType);
          if (updData != null) {
            countUpgrade++;
          }
        }
      }
    }
    return countUpgrade;
  }

  void parseResetData(Map<String, dynamic> parseJson, Map<String, int> maxRevisionByType) {
    // Если ревизия на сервере меньше чем на устройстве будет возвращён блок serverNeedUpgrade
    if (parseJson["serverNeedUpgrade"] != null) {
      for (MapEntry<String, dynamic> item in parseJson["serverNeedUpgrade"].entries) {
        DataType dataType = Util.dataTypeValueOf(item.key);
        if (dataType.isUserData()) {
          Util.log("!!!SERVER NEED UPGRADE from $item .. ${maxRevisionByType[dataType.name]}", type: "error");
          // Пометим это лаг в локальнйо БД revision = 0, что бы данные заново прошли синхронизацию
          // Грубо говоря - это восстановление данных на сервере
          // Конечно вероятность такого мала, но на всякий случай, если сервер когда-нибудь невозвратимо утухнет
          DataGetter.resetRevision(
            dataType,
            item.value,
            maxRevisionByType[dataType.name]!,
          );
        } else {
          Util.log("(NOT USER DATA)!!!SERVER NEED UPGRADE from $item .. ${maxRevisionByType[dataType.name]}",
              type: "error");
        }
      }
    }
  }

  Future<SyncResult> sync([List<String>? lazy]) async {
    if (taskQueue.length > 5) {
      //Такой кейс: небыло интернета - очередь накопилась и смысла никакого в 1000 синхронизациях нет
      // когда интернет появился мы начали шмалять запросы из очереди)
      taskLoop();
      return Future.delayed(const Duration(seconds: 1), () {
        SyncResult syncResult = SyncResult(0);
        syncResult.setError("taskQueue overflow");
        return syncResult;
      });
    } else {
      // Если нет интернета мы синхронизации будем завершать 0 return in Future
      // То есть отсутствие интернета или недоступность сервера не будет накапливать очередь
      // timeout по умолчанию 3 секунды, после этого 0 return in Future
      //TODO: проверить реально ли отсутствие интернета не накапливает очередь, очень странно откуда появился taskQueue.length > 5
      Completer<SyncResult> completer = Completer();
      taskQueue.add(TaskSync(lazy, (SyncResult syncResult) {
        completer.complete(syncResult);
      }));
      taskLoop();
      return completer.future;
    }
  }

  bool isRun = false;

  Future<void> taskLoop() async {
    if (!isRun) {
      isRun = true;
      while (taskQueue.isNotEmpty && appIsActive) {
        TaskSync task = taskQueue.removeFirst();
        SyncResult syncResult = await _syncNative(task);
        if (task.callback != null) {
          task.callback!(syncResult);
        }
      }
      isRun = false;
    }
  }

  Future<SyncResult> _syncNative(TaskSync taskSync) async {
    SyncResult syncResult = SyncResult(0);
    int sumUpgrade = 0;
    bool flagOpenLoader = false;
    int firstTotalCountItem = -1;
    int start = Util.getTimestampMillis();
    int countRequest = 1;
    try {
      Map<String, int> maxRevisionByType = await DataGetter.getMaxRevisionByType(taskSync.lazy);
      while (true) {
        // Сервер выдаёт пачки по 100kb
        // на LTE выдавать пачки большего размера не целесообразно
        // Лучше мельче нарезать, чем пропихивать 5mb одной пачкой
        if (countRequest > 100) {
          Util.p("DataSync.handler() break infinity while");
          break;
        }
        // тут именно больше 2, так как если были обновления, синхронизация будет делать 2 запроса и будет
        // всплывать лоадер, а это просто проверка
        if (countRequest > 2 && !flagOpenLoader) {
          openLoader();
          flagOpenLoader = true;
        }

        // Сокеты работают без авторизации, значит и блок removed выходит за рамки авторизации, так как удалять можно
        // все персональные данные [socket, userDataRSync, blobRSync]
        List<String> removed = await DataGetter.getRemovedUuid();

        Map<String, dynamic> postDataRequest = {
          "authJustNow": getAuthJustNow(),
          "maxRevisionByType": maxRevisionByType,
          "userDataRSync": [],
          "blobRSync": [],
          "socket": //Только на первой итерации цикла мы посылаем не синхронизованные данные,
              // все остальные итерации нужны для дозагрузки данных, которые переваливают
              // за 1000 ревизий на сервере или превышают 100kb
              countRequest == 1 ? await DataGetter.getAddSocketData() : [],
          "lazy": taskSync.lazy,
          "removed": removed.isNotEmpty ? removed : []
        };

        //Добавляем только в том случаи если пользователь авторизовался и это перввая итерация while,
        // а то на сервере не к чему будет привязывать данные
        // + это не проверка ленивых данных (словил ошибку из-за этого) данные начинают отправлятся
        // которые не прошли синхронизацию, и приходят обновления ревизии по ним,
        // что приводит к syncResult.countUpgrade > 0 ,
        // а это вызывает перезагрузку DynamicPage widget.reload(true, "lazySync complete");
        // А по факту все ленивые данные не нуждались в синхронизации и перезагрузка страницы была ложной
        if (Storage().get("isAuth", "false") == "true" && countRequest == 1 && taskSync.lazy.isEmpty) {
          postDataRequest["userDataRSync"] = await DataGetter.getUpdatedUserData();
          postDataRequest["blobRSync"] = await DataGetter.getUpdatedBlobData();
        }

        Response response = await Util.asyncInvokeIsolate((args) {
          return HttpClient.post("${args["host"]}/Sync", args["body"], args["headers"], args["debug"]);
        }, {
          "headers": HttpClient.upgradeHeadersAuthorization({}),
          "body": postDataRequest,
          "host": GlobalSettings().host,
          "debug": GlobalSettings().debugDataSync
        });

        if (response.statusCode == 200) {
          int countUpgrade = 0;
          Map<String, dynamic> parseJson = await Util.asyncInvokeIsolate((arg) => json.decode(arg), response.body);
          if (parseJson["status"] == true) {
            if (firstTotalCountItem == -1) {
              firstTotalCountItem = parseJson["totalCountItem"];
            }
            if (flagOpenLoader) {
              updateLoaderStatus(parseJson, firstTotalCountItem);
            }
            countUpgrade = parseUpgradeData(parseJson, maxRevisionByType);
            sumUpgrade += countUpgrade;
            parseResetData(parseJson, maxRevisionByType);
          }
          //Если не было инсертов, нет смысла более опрашивать сервер на предмет новых ревизий
          if (countUpgrade < 1) {
            break;
          }
        } else if (response.statusCode == 401) {
          // Мы оказывается не авторизованы
          // Такое может случится, если сервер переедет без восстановления БД
          // Мы должны разлогинится без удаления каких либо данных
          Util.log("Server Crash", type: "error");
          await DataGetter.crashServer();
          await DataGetter.logout();
          break;
        } else {
          syncResult.setError("Сервер вернул ошибку: ${response.statusCode}");
          //Серверу плохо, остановим долбление
          break;
        }
        countRequest++;
      }
      // При HotReload страница Account уже загрузится,
      // Не пугайтесь всегда будет отставание на одно значение от реальности
      Storage().set("lastSync", "${Util.getTimestamp()}");
    } catch (e, stacktrace) {
      syncResult.setError(e.toString());
      Util.printStackTrace("DataSync().sync()", e, stacktrace);
    }
    Util.p("sync time: ${Util.getTimestampMillis() - start}; sumUpgrade: $sumUpgrade; countRequest: $countRequest");
    if (flagOpenLoader && NavigatorApp.getLast() != null) {
      DynamicInvoke().sysInvokeType(CustomLoaderCloseHandler, {}, NavigatorApp.getLast()!.dynamicUIBuilderContext);
    }
    syncResult.countUpgrade = sumUpgrade;
    return syncResult;
  }

  Data? upgradeData(Map<String, dynamic> curData, DataType dataType, Map<String, int> maxRevisionByType) {
    // По факту пустого uuid быть не может, это ответвление на needUpgrade, который вышел в отлеьную структуру
    // Но остаётся по сегодняшний день, как дополнительная проверка
    if (curData["uuid"] != null && curData["uuid"] != "") {
      Data dataObject = Data(curData["uuid"], curData["value"], dataType, curData["parent_uuid"]);
      dataObject.dateAdd = curData["date_add"];
      dataObject.dateUpdate = curData["date_update"];
      dataObject.key = curData["key"];
      dataObject.meta = curData["meta"];
      dataObject.revision = curData["revision"];
      dataObject.onUpdateResetRevision = false;
      dataObject.beforeSync = true;
      dataObject.onUpdateOverlayNullField = true;
      dataObject.isRemove = curData["is_remove"];
      dataObject.parentUuid = curData["parent_uuid"];
      dataObject.lazySync = curData["lazy_sync"];
      if (curData.containsKey("sync_revision") && curData["sync_revision"] == true) {
        dataObject.notify = false;
      }
      DataSource().setData(dataObject);
      //Сервер должен выдавать отсортированные ревизии
      if (dataObject.revision != null) {
        maxRevisionByType[dataType.name] = dataObject.revision!;
      }
      return dataObject;
    }
    return null;
  }

  void init() {
    Util.p("DataSync.init()");
    DataSource().subscribe("DataSync.json", (uuid, data) {
      if (data != null) {
        Util.p("DataSync.init.onChange() => $data");
        restart(data["cron"]);
      }
    });
    SystemNotify().subscribe(SystemNotifyEnum.appLifecycleState, (state) {
      appIsActive = state == AppLifecycleState.resumed.name;
      if (appIsActive) {
        sync();
      }
      Util.p("DataSync:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $appIsActive");
    });
  }
}

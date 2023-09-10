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

class DataSync {
  static final DataSync _singleton = DataSync._internal();

  factory DataSync() {
    return _singleton;
  }

  DataSync._internal();

  Cron? cron;
  bool appIsActive = true;
  bool isRun = false;
  Timer? timer;

  void restart(String template) async {
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

  Future<void> sync() async {
    if (appIsActive && !isRun) {
      isRun = true;
      bool openLoader = false;
      int start = Util.getTimestamp();
      int allInsertion = 0;
      int firstTotalCountItem = -1;
      try {
        int counter = 0;
        Map<String, int> maxRevisionByType = await DataGetter.getMaxRevisionByType();
        while (true) {
          // Сервер выдаёт пачки по 100kb
          // на LTE выдавать пачки большего размера не целесообразно
          // Лучше мельче нарезать, чем пропихивать 5mb одной пачкой
          if (counter > 1000) {
            //Default = 20
            Util.p("DataSync.handler() break infinity while");
            break;
          }
          if (counter > 2) {
            if (!openLoader) {
              DynamicInvoke()
                  .sysInvokeType(CustomLoaderOpenHandler, {}, NavigatorApp.getLast()!.dynamicUIBuilderContext);
              openLoader = true;
            }
          }
          counter++;
          Map<String, dynamic> postDataRequest = {
            "maxRevisionByType": maxRevisionByType,
            //Добавляем только в том случаи если пользователь авторизовался и это перввая итерация while, а то на сервере не к чему будет привязывать данные
            "userDataRSync": [],
            "blobRSync": [],
            "socket": //Только на первой итерации цикла мы посылаем не синхронизованные данные, все остальные итерации нужны для дозагрузки данных, которые переваливают за 1000 ревизий на сервере
                counter == 1 ? await DataGetter.getAddSocketData() : []
          };
          // Сокеты работают без авторизации, значит и блок removed выходит за рамки авторизации, так как удалять можно
          // все персональные данные socket, userDataRSync, blobRSync
          List<String> removed = await DataGetter.getRemovedUuid();
          if (removed.isNotEmpty) {
            postDataRequest["removed"] = removed;
          }
          if (Storage().get("isAuth", "false") == "true" && counter == 1) {
            postDataRequest["userDataRSync"] = await DataGetter.getUpdatedUserData();
            postDataRequest["blobRSync"] = await DataGetter.getUpdatedBlobData();
          }
          // Util.p("sync request");
          // Util.p(Util.jsonPretty(postDataRequest));
          Response response = await Util.asyncInvokeIsolate((args) {
            return HttpClient.post("${args["host"]}/Sync", args["body"], args["headers"]);
          }, {
            "headers": HttpClient.upgradeHeadersAuthorization({}),
            "body": postDataRequest,
            "host": GlobalSettings().host,
          });
          // Util.p(
          //     "DataSync.sync() Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
          if (response.statusCode == 200) {
            int insertion = 0;
            Map<String, dynamic> parseJson = await Util.asyncInvokeIsolate((arg) => json.decode(arg), response.body);
            if (parseJson["status"] == true) {
              if (firstTotalCountItem == -1) {
                firstTotalCountItem = parseJson["data"]["totalCountItem"];
              }
              int curTotalCountItem = parseJson["data"]["totalCountItem"];
              if (openLoader) {
                DynamicInvoke().sysInvokeType(
                  ControllerHandler,
                  {
                    "controller": "loader",
                    "data": {"prc": ((firstTotalCountItem - curTotalCountItem) * 100 / firstTotalCountItem).ceil()}
                  },
                  NavigatorApp.getLast()!.dynamicUIBuilderContext,
                );
              }
              for (MapEntry<String, dynamic> item in parseJson["data"]["response"].entries) {
                DataType dataType = Util.dataTypeValueOf(item.key);
                for (Map<String, dynamic> curData in item.value) {
                  Data? updData = upgradeData(curData, dataType, maxRevisionByType);
                  if (updData != null) {
                    insertion++;
                    allInsertion++;
                  }
                }
              }
            }
            if (insertion == 0) {
              //Подумал, что слишком много запросов на синхронизацию
              //Если не было инсертов, нет смысла более опрашивать сервер на предмет новых ревизий
              break;
            }
          } else {
            //Сервер какой-то не очень отзывчивый на 200 код) Остановим долбление
            Util.p(
                "DataSync.sync() Error! Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
            break;
          }
        }
        // При HotReload страница Account уже загрузится,
        // Не пугайтесь всегда будет отставание на одно значение от реальности
        Storage().set("lastSync", "${Util.getTimestamp()}");
      } catch (e, stacktrace) {
        Util.printStackTrace("DataSync().sync()", e, stacktrace);
      }
      Util.p("sync time: ${Util.getTimestamp() - start}; insertion: $allInsertion;");
      if (openLoader) {
        DynamicInvoke().sysInvokeType(CustomLoaderCloseHandler, {}, NavigatorApp.getLast()!.dynamicUIBuilderContext);
      }
      isRun = false;
    } else {
      // История: 3 последовательных оповещения через сокет, что надо обновить
      // 1 запускает синхронизацию, 2 последних заходим сюда, в итоге последний апдейт не синхронизован
      // Потому что там процесс синхронизации успел зацепить с сервера 2 обновления, а третий не попал в временой диапозон
      // Но и тут мы обновление не дали сделать, так как уже был процесс синхронизации
      // Просераем в итоге данные, поэтому пост обновление делаем
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(const Duration(seconds: 1), () {
        Util.p("Delay sync()");
        sync();
      });
      Util.p("Sync Already, start delay");
    }
  }

  Data? upgradeData(Map<String, dynamic> curData, DataType dataType, Map<String, int> maxRevisionByType) {
    if (curData["uuid"] != null && curData["uuid"] != "") {
      Data dataObject = Data(curData["uuid"], curData["value"], dataType, curData["parent_uuid"]);
      dataObject.dateAdd = curData["date_add"];
      dataObject.dateUpdate = curData["date_update"];
      dataObject.key = curData["key"];
      dataObject.revision = curData["revision"];
      dataObject.onUpdateResetRevision = false;
      dataObject.beforeSync = true;
      dataObject.onUpdateOverlayNullField = true;
      dataObject.isRemove = curData["is_remove"];
      DataSource().setData(dataObject);
      //Сервер должен выдавать отсортированные ревизии
      maxRevisionByType[dataType.name] = dataObject.revision!;
      return dataObject;
    } else if (curData["needUpgrade"] != null) {
      //Если ревизия на сервере оказалась меньше чем на устройстве
      //Сервер высылает нам в needUpgrade актульный номер ревизии на серевере
      // Что бы мы ему повторно выслали данные с устройства этот лаг недастающих ревизий
      Util.p("!!!NEED UPGRADE from ${curData["needUpgrade"]} .. ${maxRevisionByType[dataType.name]}");
      // Данные которые готовятся к синхронизации с сервером помечаютсчя revision = 0
      // Пометим это лаг в локальнйо БД revision = 0, что бы данные заново прошли синхронизацию
      DataGetter.resetRevision(
        dataType,
        curData["needUpgrade"],
        maxRevisionByType[dataType.name]!,
      );
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

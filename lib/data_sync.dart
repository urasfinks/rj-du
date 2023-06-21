import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:rjdu/storage.dart';
import 'data_type.dart';
import 'db/data_source.dart';
import 'global_settings.dart';
import 'http_client.dart';
import 'system_notify.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'db/data.dart';
import 'db/data_getter.dart';

/*
* [Общая информация]
*
* Если у данных ревизия = 0 - это значит, что данные не синхронизованны с внешней БД
* Синхронизация доступна только для типов данных заканчивающихсяна на RSync (Remote Synchronization) в текущий момент это единственный тип: userDataRSync
*
* Возможные сценарии значений:
* [0] При вставке по умолчанию
* [0] При обновлении если устаноавлен флаг updateIfExist = true и onUpdateNeedSync = true
* [~] При вставке с предзаполненным revision
* [~] При обновлении данных если updateIfExist = true и onUpdateNeedSync = false и cloneFieldIfNull = true
* */

class DataSync {
  static final DataSync _singleton = DataSync._internal();

  factory DataSync() {
    return _singleton;
  }

  DataSync._internal();

  Cron? cron;
  bool isActive = true;
  bool isRun = false;

  void restart(String template) async {
    try {
      if (cron != null) {
        await cron!.close();
      }
      cron = Cron();
      cron!.schedule(Schedule.parse(template), sync);
      sync();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("Exception: $e; Stacktrace: $stacktrace");
      }
    }
  }

  void sync() async {
    if (isActive && !isRun) {
      isRun = true;
      int start = Util.getTimestamp();
      int allInsertion = 0;
      try {
        int counter = 0;
        Map<String, int> maxRevisionByType =
            await DataGetter.getMaxRevisionByType();
        while (true) {
          if (counter > 1) {
            //Default = 20
            if (kDebugMode) {
              print('DataSync.handler() break infinity while');
            }
            break;
          }
          counter++;
          Map<String, dynamic> postDataRequest = {
            "maxRevisionByType": maxRevisionByType,
            "userDataRSync": //Добавляем только в том случаи если пользователь авторизовался и это перввая итерация while, а то на сервере не к чему будет привязывать данные
                (Storage().get("isAuth", "false") == "true" && counter == 1)
                    ? await DataGetter.getUpdatedUserData()
                    : [],
            "socket": //Только на первой итерации цикла мы посылаем не синхронизованные данные, все остальные итерации нужны для дозагрузки данных, которые переваливают за 1000 ревизий на сервере
                counter == 1 ? await DataGetter.getAddSocketData() : []
          };

          if (kDebugMode) {
            print(
                "DataSync.sync(${GlobalSettings().host}/Sync) ${Util.jsonPretty(postDataRequest)}");
          }

          Response response = await Util.asyncInvokeIsolate((args) {
            return HttpClient.post(
                "${args["host"]}/Sync", args["body"], args["headers"]);
          }, {
            "headers": HttpClient.upgradeHeadersAuthorization({}),
            "body": postDataRequest,
            "host": GlobalSettings().host,
          });
          if (kDebugMode) {
            print(
                "DataSync.sync() Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
          }
          if (response.statusCode == 200) {
            int insertion = 0;
            Map<String, dynamic> parseJson = await Util.asyncInvokeIsolate(
                (arg) => json.decode(arg), response.body);
            if (parseJson["status"] == true) {
              for (MapEntry<String, dynamic> item
                  in parseJson["data"]["response"].entries) {
                DataType dataType = Util.dataTypeValueOf(item.key);
                for (Map<String, dynamic> curData in item.value) {
                  if (upgradeData(curData, dataType, maxRevisionByType)) {
                    insertion++;
                    allInsertion++;
                  }
                }
              }
            }
            if (insertion == 0) {
              //Если не было инсертов, нет смысла более опрашивать сервер на предмет новых ревизий
              break;
            }
          } else {
            //Сервер какой-то не очень отзывчивый на 200 код) Остановим долбление
            break;
          }
        }
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print(e);
          print(stacktrace);
        }
      }
      if (kDebugMode) {
        print(
            "sync time: ${Util.getTimestamp() - start}; insertion: $allInsertion");
      }
      isRun = false;
    }
  }

  bool upgradeData(Map<String, dynamic> curData, DataType dataType,
      Map<String, int> maxRevisionByType) {
    if (curData['uuid'] != null && curData['uuid'] != "") {
      Data dataObject = Data(
          curData['uuid'], curData['value'], dataType, curData['parent_uuid']);
      dataObject.dateAdd = curData['date_add'];
      dataObject.dateUpdate = curData['date_update'];
      dataObject.key = curData['key'];
      dataObject.revision = curData['revision'];
      dataObject.onUpdateResetRevision = false;
      dataObject.beforeSync = true;
      dataObject.onUpdateOverlayNullField = true;
      dataObject.isRemove = curData['is_remove'];
      //print("! $dataObject");
      DataSource().setData(dataObject);
      //Сервер должен выдавать отсортированные ревизии
      maxRevisionByType[dataType.name] = dataObject.revision!;
      return true;
    } else if (curData['needUpgrade'] != null) {
      //Если ревизия на сервере оказалась меньше чем на устройстве
      //Сервер высылает нам в needUpgrade актульный номер ревизии на серевере
      // Что бы мы ему повторно выслали данные с устройства этот лаг недастающих ревизий
      print(
          "!!!NEED UPGRADE from ${curData['needUpgrade']} .. ${maxRevisionByType[dataType.name]}");
      // Данные которые готовятся к синхронизации с сервером помечаютсчя revision = 0
      // Пометим это лаг в локальнйо БД revision = 0, что бы данные заново прошли синхронизацию
      DataGetter.resetRevision(
        dataType,
        curData['needUpgrade'],
        maxRevisionByType[dataType.name]!,
      );
    }
    return false;
  }

  void init() {
    if (kDebugMode) {
      print("DataSync.init()");
    }
    DataSource().subscribe("DataSync.json", (uuid, data) {
      if (data != null) {
        if (kDebugMode) {
          print("DataSync.init.onChange() => $data");
        }
        restart(data["cron"]);
      }
    });
    SystemNotify().listen(SystemNotifyEnum.appLifecycleState, (state) {
      isActive = state == AppLifecycleState.resumed.name;
      if (isActive) {
        sync();
      }
      if (kDebugMode) {
        print(
            "DataSync:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $isActive");
      }
    });
  }
}

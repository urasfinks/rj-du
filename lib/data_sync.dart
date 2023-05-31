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
          if (counter > 20) {
            if (kDebugMode) {
              print('DataSync.handler() break infinity while');
            }
            break;
          }
          counter++;
          Map<String, dynamic> postDataRequest = {
            "maxRevisionByType": maxRevisionByType,
            "userData": Storage().get("isAuth", "false") ==
                    "true" //Добавляем только в том случаи если пользователь авторизовался, а то на сервере не к чему будет привязывать данные
                ? await DataGetter.getUpdatedUserData()
                : [],
            "socketData": await DataGetter.getAddSocketData()
          };
          var example = {
            "maxRevisionByType": {
              "js": 0,
              "socket": 0,
              "systemData": 0,
              "template": 0,
              "userDataRSync": 0,
              "any": 0
            },
            "userData": [
              {
                "id_data": 26,
                "uuid_data": "500efb3e-8dfe-4b77-a536-9ea866a1ffe4",
                "value_data": "{\"label\":\"Хьюмидор\"}",
                "type_data": "userDataRSync",
                "parent_uuid_data": null,
                "key_data": "humidor",
                "date_add_data": 1685559500427,
                "date_update_data": null,
                "revision_data": 0,
                "is_remove_data": 0
              }
            ],
            "socketData": [
              {
                "id_data": 27,
                "uuid_data": "test",
                "value_data": "{}",
                "type_data": "socket",
                "parent_uuid_data": null,
                "key_data": null,
                "date_add_data": 1685559656447,
                "date_update_data": null,
                "revision_data": 0,
                "is_remove_data": 0
              },
              {
                "id_data": 28,
                "uuid_data": "test2",
                "value_data": "{}",
                "type_data": "socket",
                "parent_uuid_data": "test",
                "key_data": null,
                "date_add_data": 1685559656448,
                "date_update_data": null,
                "revision_data": 0,
                "is_remove_data": 0
              }
            ]
          };
          if (kDebugMode) {
            print(
                "DataSync.sync(${GlobalSettings().host}/sync) ${Util.jsonPretty(postDataRequest)}");
          }

          Response response = await Util.asyncInvokeIsolate((args) {
            return HttpClient.post(
                "${args["host"]}/sync", args["body"], args["headers"]);
          }, {
            "headers": HttpClient.upgradeHeadersAuthorization({}),
            "body": postDataRequest,
            "host": GlobalSettings().host,
          });
          if (kDebugMode) {
            print(
                "ResponseCode: ${response.statusCode} Response: ${response.body}");
          }
          if (response.statusCode == 200) {
            int insertion = 0;
            Map<String, dynamic> parseJson = await Util.asyncInvokeIsolate(
                (arg) => json.decode(arg), response.body);

            for (MapEntry<String, dynamic> item in parseJson.entries) {
              DataType dataType = Util.dataTypeValueOf(item.key);
              List<dynamic> list = item.value;
              for (Map<String, dynamic> curData in list) {
                if (curData['uuid'] != null && curData['uuid'] != "") {
                  Data dataObject = Data(curData['uuid'], curData['value'],
                      dataType, curData['parent_uuid']);
                  dataObject.dateAdd = curData['date_add'];
                  dataObject.dateUpdate = curData['date_update'];
                  dataObject.key = curData['key'];
                  dataObject.revision = curData['revision'];
                  dataObject.onUpdateResetRevision = false;
                  dataObject.cloneFieldIfNull = true;
                  dataObject.isRemove = curData['is_remove'];
                  DataSource().setData(dataObject);
                  maxRevisionByType[dataType.name] = dataObject.revision!;
                  insertion++;
                  allInsertion++;
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

  void init() {
    if (kDebugMode) {
      print("DataSync.init()");
    }
    DataSource().onChange("DataSync.json", (data) {
      if (data != null) {
        if (kDebugMode) {
          print("DataSync.init.onChange() => $data");
        }
        restart(data["cron"]);
      }
    });
    SystemNotify().listen(SystemNotifyEnum.appLifecycleState, (state) {
      isActive = state == AppLifecycleState.resumed.name;
      if (kDebugMode) {
        print(
            "DataSync:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $isActive");
      }
    });
  }
}

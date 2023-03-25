import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'data_type.dart';
import 'db/data_source.dart';
import 'global_settings.dart';
import 'http_client.dart';
import 'system_notify.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'db/data.dart';
import 'db/data_getter.dart';

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
      cron!.schedule(Schedule.parse(template), handler);
      handler();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("Exception: $e; Stacktrace: $stacktrace");
      }
    }
  }

  void handler() async {
    if (isActive && !isRun) {
      int start = Util.getTimestamp();
      int allInsertion = 0;
      isRun = true;
      try {
        int counter = 0;
        Map<String, int> maxRevisionByType = await DataGetter.getMaxRevisionByType();
        for (DataType dataType in DataType.values) {
          if (!maxRevisionByType.containsKey(dataType.name)) {
            if (dataType != DataType.virtual) {
              maxRevisionByType[dataType.name] = 0;
            }
          }
        }
        //print("Max: $maxRevisionByType");
        while (true) {
          if (counter > 20) {
            if (kDebugMode) {
              print('DataSync.handler() break infinity while');
            }
            break;
          }
          counter++;

          print("Request: $maxRevisionByType");
          Response response = await Util.asyncInvokeIsolate((args) {
            return HttpClient.post("${GlobalSettings.host}/sync", args["body"], args["headers"]);
          }, {
            "headers": HttpClient.upgradeHeadersAuthorization({}),
            "body": maxRevisionByType,
          });
          //print("ResponseCode: ${response.statusCode}");
          if (response.statusCode == 200) {
            int insertion = 0;
            Map<String, dynamic> parseJson = await Util.asyncInvokeIsolate((arg) => json.decode(arg), response.body);

            for (MapEntry<String, dynamic> item in parseJson.entries) {
              DataType dataType = Util.dataTypeValueOf(item.key);
              List<dynamic> list = item.value;
              for (Map<String, dynamic> curData in list) {
                Data dataObject = Data(curData['uuid'], curData['value'], dataType, curData['parent_uuid']);
                dataObject.dateAdd = curData['date_add'];
                dataObject.dateUpdate = curData['date_update'];
                dataObject.key = curData['key'];
                dataObject.revision = curData['revision'];
                dataObject.isRemove = curData['is_remove'];
                //print(dataObject.revision);
                DataSource().setData(dataObject);
                maxRevisionByType[dataType.name] = dataObject.revision!;
                insertion++;
                allInsertion++;
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
          //print("HttpClient.post() => HttpCode:  ${response.statusCode}; Body: ${response.body}");
        }
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print(e);
          print(stacktrace);
        }
      }
      print("sync time: ${Util.getTimestamp() - start}; insertion: $allInsertion");
      isRun = false;
    }
  }

  void init() {
    DataSource().onChange("DataSync.json", (data) {
      if (data != null) {
        print("DataSync.init.onChange() => $data");
        restart(data["cron"]);
      }
    });
    SystemNotify().listen(SystemNotifyEnum.appLifecycleState, (state) {
      isActive = state == AppLifecycleState.resumed.name;
      if (kDebugMode) {
        print("DataSync:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $isActive");
      }
    });
  }
}

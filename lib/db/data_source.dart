import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rjdu/data_sync.dart';
import 'package:rjdu/db/socket_cache.dart';
import 'package:rjdu/dynamic_invoke/handler/alert_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../data_type.dart';
import '../../http_client.dart';
import '../global_settings.dart';
import '../navigator_app.dart';
import '../util.dart';
import 'data_migration.dart';
import 'getter_task.dart';
import 'data.dart';

class DataSource {
  static final DataSource _singleton = DataSource._internal();

  factory DataSource() {
    return _singleton;
  }

  DataSource._internal();

  bool isInit = false;
  List<dynamic> list = [];
  List<DataType> notJsonList = [DataType.js, DataType.any, DataType.blob, DataType.blobRSync];
  late Database db;
  Map<String, List<Function(String uuid, Map<String, dynamic>? data)>> listener = {};
  DataMigration dataMigration = DataMigration();

  init() async {
    if (kDebugMode) {
      print("DataSource.init()");
    }
    final directory = await getApplicationDocumentsDirectory();
    db = await openDatabase("${directory.path}/mister-craft-1.sqlite3", version: 1);
    await dataMigration.init();
    isInit = true;
    flushQueue();
  }

  bool isJsonDataType(DataType? dataType) {
    if (dataType == null) {
      return false;
    }
    return !notJsonList.contains(dataType);
  }

  void flushQueue() {
    var count = 0;
    if (isInit) {
      while (list.isNotEmpty) {
        var remove = list.first;
        if (remove.runtimeType == Data) {
          Data dataInsertion = remove as Data;
          setData(dataInsertion);
        } else if (remove.runtimeType == GetterTask) {
          get(remove.uuid, remove.handler);
        }
        list.remove(remove);
        count++;
      }
    }
    debugPrint("flushQueue complete: $count");
  }

  void set(String uuid, dynamic value, DataType type, [String? key, String? parent, bool updateIfExist = true]) {
    Data data = Data(uuid, value, type, parent);
    data.key = key;
    data.updateIfExist = updateIfExist;
    setData(data);
  }

  void setData(Data data, [bool notifyDynamicPage = true]) {
    List<String> transaction = [];
    if (isInit) {
      transaction.add("1 is init");
      if (data.type == DataType.virtual) {
        //Состояние страницы (для виртуалок beforeSync не актуален)
        setDataVirtual(data, transaction, notifyDynamicPage);
      } else if (data.type == DataType.socket && data.beforeSync == false) {
        //В runtime изменили данные
        setDataSocket(data, transaction, notifyDynamicPage);
      } else {
        //Если beforeSync = true, попадём сюда!
        setDataStandard(data, transaction, notifyDynamicPage);
      }
    } else {
      transaction.add("10 not init");
      list.add(data);
      printTransaction(data, transaction);
    }
  }

  void printTransaction(Data data, List<String> transaction) {
    if (kDebugMode && data.debugTransaction) {
      print("setData: ${data.uuid} transaction: $transaction");
    }
  }

  void setDataStandard(Data data, List<String> transaction, bool notifyDynamicPage) {
    transaction.add("5 saveToDB");
    db.rawQuery("SELECT * FROM data where uuid_data = ?", [data.uuid]).then((resultSet) {
      bool notify = false;
      if (resultSet.isEmpty) {
        transaction.add("6 result is empty > insert");
        insert(data);
        notify = true;
        if (data.type == DataType.socket) {
          // После того как мы вставили сокетные данные
          // Надо запустить синхронизацию
          // Что бы эта запись на сервер уползла
          transaction.add("6.1 DataSync().sync()");
          DataSync().sync();
        }
      } else if (data.updateIfExist == true) {
        transaction.add("7 result not empty > update");
        //resultSet.first["value_data"] != dataString
        // данные надо иногда обновлять не только потому что изменились
        // сами данные, бывает что надо бновить флаг удаления или ревизию
        updateNullable(data, resultSet.first);
        update(data);
        notify = true;
      } else {
        transaction.add("8 NOTHING!");
      }
      if (data.type == DataType.socket && data.beforeSync == true) {
        SocketCache().setFull(data);
      } else if (notify) {
        notifyBlockAsync(data, transaction, notifyDynamicPage);
      } else {
        printTransaction(data, transaction);
      }
    });
  }

  void notifyBlockAsync(Data data, List<String> transaction, bool notifyDynamicPage) {
    if (notifyDynamicPage) {
      transaction.add("3 notifyBlock()");
      //Что бы не было коллизии setState или marketRebuild во время build
      Util.asyncInvoke((args) {
        try {
          notifyBlock(args);
        } catch (e, stacktrace) {
          if (kDebugMode) {
            debugPrintStack(
              stackTrace: stacktrace,
              maxFrames: GlobalSettings().debugStackTraceMaxFrames,
              label: "DataSource.notifyBlockAsync() Exception: $e; args: $args",
            );
          }
        }
      }, data);
    }
    printTransaction(data, transaction);
  }

  void setDataVirtual(Data data, List<String> transaction, bool notifyDynamicPage) {
    transaction.add("2 is virtual");
    notifyBlockAsync(data, transaction, notifyDynamicPage);
  }

  void setDataSocket(Data diffData, List<String> transaction, bool notifyDynamicPage) {
    print("setDataSocket(${diffData.uuid}) notify: $notifyDynamicPage");
    // Обновление сокетных данных не должно обновлять локальную БД
    transaction.add("4 update socket data");
    if (notifyDynamicPage) {
      SocketCache().setDiff(diffData);
    }
    sendDataSocket(diffData, notifyDynamicPage);
    printTransaction(diffData, transaction);
  }

  void sendDataSocket(Data data, bool notifyDynamicPage) async {
    Map<String, dynamic> postData = {"uuid_data": data.uuid, "data": data.value};
    try {
      Response response = await Util.asyncInvokeIsolate((args) {
        return HttpClient.post("${args["host"]}/SocketUpdate", args["body"], args["headers"]);
      }, {
        "headers": HttpClient.upgradeHeadersAuthorization({}),
        "body": postData,
        "host": GlobalSettings().host,
      });
      if (response.statusCode == 200) {
      } else {
        AlertHandler.alertSimple("Данные не зафиксированы на сервере");
        Future.delayed(const Duration(seconds: 1), () {
          SocketCache().renderDBData(data);
        });
      }
      if (kDebugMode) {
        print(
            "DataSource.sendSocketUpdate() Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
      }
    } catch (e, stacktrace) {
      AlertHandler.alertSimple("Данные не зафиксированы на сервере");
      Future.delayed(const Duration(seconds: 1), () {
        SocketCache().renderDBData(data);
      });

      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stacktrace,
          maxFrames: GlobalSettings().debugStackTraceMaxFrames,
          label: "DataSource.sendDataSocket() Exception: $e; data: $data",
        );
      }
    }

    // тут не будем вызывать синхронизацию данных,
    // так как событие на синхронизацию должно прийти по сокету
    // После http запроса
  }

  void updateNullable(Data curData, dynamic dbResult) {
    if (curData.onUpdateOverlayNullField) {
      curData.value ??= dbResult["value_data"];
      curData.parentUuid ??= dbResult["parent_uuid_data"];
      curData.key ??= dbResult["key_data"];
      curData.dateAdd ??= dbResult["date_add_data"];
      curData.dateUpdate ??= dbResult["date_update_data"];
      curData.revision ??= dbResult["revision_data"];
      curData.isRemove ??= dbResult["is_remove_data"];
    }
  }

  void update(Data curData) {
    if (curData.onUpdateResetRevision && curData.type.name.endsWith("RSync")) {
      curData.revision = 0;
    }
    String dataString = curData.value.runtimeType != String ? json.encode(curData.value) : curData.value;
    //print("UPD: $curData");
    //print("UPD dataString: $dataString");
    db.rawUpdate(
      'UPDATE data SET value_data = ?, type_data = ?, parent_uuid_data = ?, key_data = ?, date_add_data = ?, date_update_data = ?, revision_data = ?, is_remove_data = ? WHERE uuid_data = ?',
      [
        dataString,
        curData.type.name,
        curData.parentUuid,
        curData.key,
        curData.dateAdd,
        curData.dateUpdate,
        curData.revision,
        curData.isRemove,
        curData.uuid,
      ],
    ).then((value) {
      if (curData.onPersist != null) {
        Function.apply(curData.onPersist!, null);
      }
    });
  }

  void insert(Data curData) {
    db.rawInsert(
      'INSERT INTO data (uuid_data, value_data, type_data, parent_uuid_data, key_data, date_add_data, date_update_data, revision_data, is_remove_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        curData.uuid,
        curData.value.runtimeType != String ? json.encode(curData.value) : curData.value,
        curData.type.name,
        curData.parentUuid,
        curData.key,
        curData.dateAdd ??= Util.getTimestamp(),
        curData.dateUpdate,
        curData.revision ??= 0,
        curData.isRemove ??= 0,
      ],
    ).then((value) {
      if (curData.onPersist != null) {
        Function.apply(curData.onPersist!, null);
      }
    });
  }

  void notifyBlock(Data curData) {
    Map<String, dynamic> runtimeData = {};
    if (curData.value.runtimeType == String && isJsonDataType(curData.type)) {
      runtimeData = json.decode(curData.value);
    } else if (curData.value.runtimeType != String) {
      if (curData.value.runtimeType.toString().contains("Map<dynamic, dynamic>")) {
        runtimeData = Util.getMutableMap(curData.value);
      } else {
        runtimeData = curData.value;
      }
    } else {
      runtimeData = {curData.type.name: curData.value};
    }
    //Оповещение для перестройки страниц
    if (isJsonDataType(curData.type)) {
      NavigatorApp.updatePageNotifier(curData.uuid, runtimeData);
    }
    //Оповещение программных компонентов, кто подписался на onChange
    if (listener.containsKey(curData.uuid)) {
      for (Function(String uuid, Map<String, dynamic>? data) callback in listener[curData.uuid]!) {
        callback(curData.uuid, runtimeData);
      }
    }
  }

  void get(String uuid, Function(String uuid, Map<String, dynamic>? data) handler) {
    if (isInit) {
      db.rawQuery("SELECT * FROM data where uuid_data = ?", [uuid]).then((resultSet) {
        if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
          DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
          if (isJsonDataType(dataTypeResult)) {
            //handler(await Util.asyncInvokeIsolate((arg) => json.decode(arg), resultSet.first["value_data"]));
            handler(resultSet.first["uuid_data"] as String, json.decode(resultSet.first["value_data"] as String));
          } else {
            handler(resultSet.first["uuid_data"] as String, {dataTypeResult.name: resultSet.first["value_data"]});
          }
        } else {
          handler(uuid, null);
        }
      });
    } else {
      list.add(GetterTask(uuid, handler));
    }
  }

  void subscribe(String uuid, Function(String uuid, Map<String, dynamic>? data) callback) {
    //print("subscribe: ${uuid}");
    get(uuid, callback);
    if (!listener.containsKey(uuid)) {
      listener[uuid] = [];
    }
    if (!listener[uuid]!.contains(callback)) {
      listener[uuid]!.add(callback);
    }
  }

  void unsubscribe(Function(String uuid, Map<String, dynamic>? data) callback) {
    List<String> clear = [];
    for (MapEntry<String, List<Function(String uuid, Map<String, dynamic>? data)>> item in listener.entries) {
      if (item.value.contains(callback)) {
        //print("unsubscribe: ${item.key}");
        item.value.remove(callback);
      }
      if (item.value.isEmpty) {
        clear.add(item.key);
      }
    }
    for (String key in clear) {
      listener.remove(key);
    }
  }
}

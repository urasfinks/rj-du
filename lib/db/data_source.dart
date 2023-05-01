import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../data_type.dart';
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
  List<DataType> notJsonList = [DataType.js, DataType.any];
  late Database db;
  Map<String, List<Function(Map<String, dynamic>? data)>> listener = {};
  DataMigration dataMigration = DataMigration();

  init() async {
    debugPrint('DataSource.init()');
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
    debugPrint('flushQueue complete: $count');
  }

  void set(String uuid, dynamic value, DataType type, [String? key, String? parent, bool updateIfExist = true]) {
    Data data = Data(uuid, value, type, parent);
    data.key = key;
    data.updateIfExist = updateIfExist;
    setData(data);
  }

  void setData(Data data) {
    if (isInit) {
      String dataString = data.value.runtimeType != String ? json.encode(data.value) : data.value;
      if (data.type == DataType.virtual) {
        //Что бы не было коллизии setState или marketRebuild во время build
        Util.asyncInvoke((args) {
          notifyBlock(data);
        }, data);
      } else {
        db.rawQuery('SELECT * FROM data where uuid_data = ?', [data.uuid]).then((resultSet) {
          bool notify = false;
          if (resultSet.isEmpty) {
            insert(data, dataString);
            notify = true;
          } else if (data.updateIfExist == true && resultSet.first['value_data'] != dataString) {
            updateNullable(data, resultSet.first);
            update(data, dataString);
            notify = true;
          }
          if (notify) {
            notifyBlock(data);
          }
        });
      }
    } else {
      list.add(data);
    }
  }

  void updateNullable(Data curData, dynamic dbResult) {
    if (curData.cloneFieldIfNull) {
      curData.value ??= dbResult['value_data'];
      curData.parentUuid ??= dbResult['parent_uuid_data'];
      curData.key ??= dbResult['key_data'];
      curData.dateAdd ??= dbResult['date_add_data'];
      curData.dateUpdate ??= dbResult['date_update_data'];
      curData.revision ??= dbResult['revision_data'];
      curData.isRemove ??= dbResult['is_remove_data'];
    }
    if (curData.onUpdateResetRevision && curData.type.runtimeType.toString().endsWith("RSync")) {
      curData.revision = 0;
    }
  }

  void update(Data curData, String dataString) {
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

  void insert(Data curData, String dataString) {
    db.rawInsert(
      'INSERT INTO data (uuid_data, value_data, type_data, parent_uuid_data, key_data, date_add_data, date_update_data, revision_data, is_remove_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        curData.uuid,
        dataString,
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
      for (Function(Map<String, dynamic>? data) callback in listener[curData.uuid]!) {
        callback(runtimeData);
      }
    }
  }

  void get(String uuid, Function(Map<String, dynamic>? data) handler) {
    if (isInit) {
      db.rawQuery('SELECT * FROM data where uuid_data = ?', [uuid]).then((resultSet) {
        if (resultSet.isNotEmpty && resultSet.first['value_data'] != null) {
          DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first['type_data'] as String?);
          if (isJsonDataType(dataTypeResult)) {
            //handler(await Util.asyncInvokeIsolate((arg) => json.decode(arg), resultSet.first['value_data']));
            handler(json.decode(resultSet.first['value_data'] as String));
          } else {
            handler({dataTypeResult.name: resultSet.first['value_data']});
          }
        } else {
          handler(null);
        }
      });
    } else {
      list.add(GetterTask(uuid, handler));
    }
  }

  void onChange(String uuid, Function(Map<String, dynamic>? data) callback) {
    get(uuid, callback);
    if (!listener.containsKey(uuid)) {
      listener[uuid] = [];
    }
    if (!listener[uuid]!.contains(callback)) {
      listener[uuid]!.add(callback);
    }
  }
}

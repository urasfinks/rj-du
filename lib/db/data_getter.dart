import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../data_type.dart';
import '../storage.dart';
import '../util.dart';
import 'data_source.dart';

class DataGetter {
  static Future<List<Map<String, dynamic>>> getUpdatedUserData() async {
    return await DataSource()
        .db
        .rawQuery("SELECT * FROM data WHERE type_data = ? AND revision_data = 0", [DataType.userDataRSync.name]);
  }

  static Future<List<Map<String, dynamic>>> getUpdatedBlobData() async {
    return await DataSource()
        .db
        .rawQuery("SELECT * FROM data WHERE type_data = ? AND revision_data = 0", [DataType.blobRSync.name]);
  }

  static Future<List<Map<String, dynamic>>> getAddSocketData() async {
    return await DataSource().db.rawQuery(
        "SELECT * FROM data WHERE type_data = ? AND revision_data = 0 and is_remove_data = 0", [DataType.socket.name]);
  }

  static Future<List<Map<String, dynamic>>> resetRevision(DataType dataType, int fromRevision, int toRevision) async {
    return await DataSource().db.rawQuery(
        "UPDATE data SET revision_data = 0 WHERE type_data = ? AND revision_data >= ? AND revision_data <= ?",
        [dataType.name, fromRevision, toRevision]);
  }

  static Future<Map<String, int>> getMaxRevisionByType() async {
    Map<String, int> result = {};
    var resultSet = await DataSource().db.rawQuery(
        "SELECT type_data, max(revision_data) as max FROM data WHERE is_remove_data = 0 GROUP BY type_data", []);
    for (Map<String, dynamic> item in resultSet) {
      result[item["type_data"]] = item["max"];
    }
    for (DataType dataType in DataType.values) {
      //Добиваем нулями несуществующие типы из БД
      if (!result.containsKey(dataType.name)) {
        if (dataType != DataType.virtual) {
          result[dataType.name] = 0;
        }
      }
    }
    return result;
  }

  static void getDataJson(String uuid, Function(String uuid, Map<String, dynamic>? data) callback) {
    //Аккуратнее поиск осуществляется ещё по parent_uuid
    DataSource().db.rawQuery("SELECT * FROM data where uuid_data = ? or parent_uuid_data = ?", [uuid, uuid]).then((resultSet) {
      if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
        DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
        if (DataSource().isJsonDataType(dataTypeResult)) {
          callback(resultSet.first["uuid_data"] as String, json.decode(resultSet.first["value_data"] as String));
        }
      }
    }).onError((error, stackTrace) {
      Util.printStackTrace("DataGetter.getDataJson() uuid: $uuid", error, stackTrace);
    });
  }

  static void getDataBlob(String uuid, Function(Uint8List? data) callback) {
    DataSource().db.rawQuery("SELECT * FROM data where uuid_data = ? and type_data IN (?,?)",
        [uuid, DataType.blob.name, DataType.blobRSync.name]).then((resultSet) {
      callback(resultSet.isEmpty ? null : Util.base64Decode(resultSet.first["value_data"] as String));
    }).onError((error, stackTrace) {
      Util.printStackTrace("DataGetter.getDataBlob() uuid: $uuid", error, stackTrace);
    });
  }

  static void debug(String sql) {
    if (sql.isNotEmpty) {
      DataSource().db.rawQuery(sql, []).then((resultSet) {
        Util.p("DataGetter.debug($sql)");
        Util.p(resultSet);
      }).onError((error, stackTrace) {
        Util.printStackTrace("DataGetter.debug()", error, stackTrace);
      });
    }
  }

  static Future<List<String>> getRemovedUuid() async {
    // Изначально было только socket/blob/blobRSync
    // Потом я посмотрел и подумал, что надо ещё userDataRSync
    // Сейчас мысли такие, что надо удалять жиреннькие данные в приоритете на сервере
    List<Map<String, dynamic>> result = await DataSource().db.rawQuery(
        "SELECT uuid_data FROM data WHERE is_remove_data = 1 AND type_data IN (?,?,?,?)",
        [DataType.socket.name, DataType.blob.name, DataType.blobRSync.name, DataType.userDataRSync.name]);
    List<String> ret = [];
    for (Map<String, dynamic> item in result) {
      ret.add(item["uuid_data"]);
    }
    return ret;
  }

  static void logout() async {
    if (Storage().get("isAuth", "false") == "true"){
      Storage().setMap({
        "mail": "",
        "isAuth": "false"
      });
      // Если не поменять uuid устройства синхронизация будет вытягивать с удалённой БД всё что было по этому uuid
      // Без вариантов надо uuid менять
      Storage().set("uuid", Util.uuid(), true);
      // Аналогично надо менять и уникальный код
      Storage().set("unique", Util.uuid(), true);
      // Данные, которые принадлежат моей учётке и синхронизованны с сервером
      // Ну получается, что если не синхронизованны, я не хочу брать на душу их удаление
      // Да, они потом примажутся к другой учётке..ну что поделать...зато не удалятся
      await DataSource().db.rawQuery(
          "DELETE FROM data WHERE type_data IN (?,?,?) AND revision_data > 0",
          [DataType.socket.name, DataType.blobRSync.name, DataType.userDataRSync.name]);
    }
  }
}

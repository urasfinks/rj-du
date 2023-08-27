import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../data_type.dart';
import '../global_settings.dart';
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

  static void getDataJson(String uuid, Function(Map<String, dynamic>? data) callback) {
    DataSource().db.rawQuery("SELECT * FROM data where uuid_data = ?", [uuid]).then((resultSet) {
      if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
        DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
        if (DataSource().isJsonDataType(dataTypeResult)) {
          callback(json.decode(resultSet.first["value_data"] as String));
        }
      }
    });
  }

  static void getDataBlob(String uuid, Function(Uint8List? data) callback) {
    DataSource().db.rawQuery("SELECT * FROM data where uuid_data = ? and type_data IN (?,?)",
        [uuid, DataType.blob.name, DataType.blobRSync.name]).then((resultSet) {
      callback(resultSet.isEmpty ? null : Util.base64Decode(resultSet.first["value_data"] as String));
    }).onError((e, stacktrace){
      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stacktrace,
          maxFrames: GlobalSettings().debugStackTraceMaxFrames,
          label: "DataGetter.getDataBlob() Exception: $e; uuid: $uuid",
        );
      }
    });
  }
}

import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:rjdu/dynamic_invoke/handler/page_reload_handler.dart';

import '../data_type.dart';
import '../dynamic_invoke/dynamic_invoke.dart';
import '../dynamic_invoke/handler/alert_handler.dart';
import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../global_settings.dart';
import '../storage.dart';
import '../util.dart';
import 'data_source.dart';
import '../../http_client.dart';

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

  static Future<Map<String, int>> getMaxRevisionByType(List<String>? lazy) async {
    Map<String, int> result = {};
    List<Map<String, Object?>> resultSet = [];
    if (lazy != null && lazy.isNotEmpty) {
      List<String> stateList = [];
      for (String _ in lazy) {
        stateList.add("?");
      }
      String sql =
          "SELECT type_data, max(revision_data) as max FROM data WHERE is_remove_data = 0 AND lazy_sync_data IN (${stateList.join(',')}) GROUP BY type_data";
      resultSet = await DataSource().db.rawQuery(sql, lazy);
    } else {
      resultSet = await DataSource().db.rawQuery(
          "SELECT type_data, max(revision_data) as max FROM data WHERE is_remove_data = 0 AND lazy_sync_data IS NULL GROUP BY type_data",
          []);
    }
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
    DataSource()
        .db
        .rawQuery("SELECT * FROM data where uuid_data = ? or parent_uuid_data = ?", [uuid, uuid]).then((resultSet) {
      if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
        DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
        if (dataTypeResult.isJson()) {
          callback(resultSet.first["uuid_data"] as String, json.decode(resultSet.first["value_data"] as String));
        }
      }
    }).onError((error, stackTrace) {
      Util.log("DataGetter.getDataJson() uuid: $uuid; Error: $error", stackTrace: stackTrace, type: "error");
    });
  }

  static void getDataBlob(String uuid, Function(Uint8List? data) callback) {
    DataSource().db.rawQuery("SELECT * FROM data where uuid_data = ? and type_data IN (?,?)",
        [uuid, DataType.blob.name, DataType.blobRSync.name]).then((resultSet) {
      callback(resultSet.isEmpty ? null : Util.base64Decode(resultSet.first["value_data"] as String));
    }).onError((error, stackTrace) {
      Util.log("DataGetter.getDataBlob() uuid: $uuid; Error: $error", stackTrace: stackTrace, type: "error");
    });
  }

  static void debug(String sql) {
    if (sql.isNotEmpty) {
      DataSource().db.rawQuery(sql, []).then((resultSet) {
        Util.p("DataGetter.debug($sql)");
        Util.log(Util.jsonPretty(resultSet));
      }).onError((error, stackTrace) {
        Util.log("DataGetter.debug(); Error: $error", stackTrace: stackTrace, type: "error");
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

  static void logoutWithRemove(DynamicUIBuilderContext dynamicUIBuilderContext) async {
    Response response = await Util.asyncInvokeIsolate((args) {
      return HttpClient.get("${args["host"]}/LogoutWithRemove", args["headers"]);
    }, {
      "headers": HttpClient.upgradeHeadersAuthorization({}),
      "host": GlobalSettings().host,
    });
    if (response.statusCode == 200) {
      AlertHandler.alertSimple("Данные учётной записи удалены c сервера");
      await logout();
      DynamicInvoke().sysInvokeType(PageReloadHandler, {"case": "current"}, dynamicUIBuilderContext);
    } else {
      AlertHandler.alertSimple("Ошибка синхронизации с сервером");
    }
  }

  // Сервер вернул при синхронизации данных ошибку авторизации, надо срочно сохранить что у нас есть личного
  static Future<void> crashServer() async {
    await DataSource().db.rawQuery("UPDATE data SET revision_data = 0 WHERE type_data IN (?,?,?)",
        [DataType.socket.name, DataType.blobRSync.name, DataType.userDataRSync.name]);
  }

  static Future<void> logout() async {
    if (Storage().get("isAuth", "false") == "true") {
      Storage().setMap({"mail": "", "isAuth": "false", "accountName": ""});
      // Если не поменять uuid устройства синхронизация будет вытягивать с удалённой БД всё что было по этому uuid
      // Без вариантов надо uuid менять
      Storage().set("uuid", Util.uuid(), true);
      // Аналогично надо менять и уникальный код
      // Мысль такая: если перелогиниться под другой учёткой и если код unique будет не заменён
      // устройство получит функционал капитана в ранее созданных играх из под другой учётки, а наверное не должно
      Storage().set("unique", Util.uuid(), true);
      // Данные, которые синхронизованны с сервером имеют revision_data > 0
      // revision_data = 0 - ожидают синхронизации, их не будем трогать
      // При аторизации они примажуться к другой учётке
      await DataSource().db.rawQuery("DELETE FROM data WHERE type_data IN (?,?,?) AND revision_data > 0",
          [DataType.socket.name, DataType.blobRSync.name, DataType.userDataRSync.name]);
    }
  }
}

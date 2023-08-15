import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rjdu/dynamic_ui/type_parser.dart';
import 'package:rjdu/storage.dart';
import '../data_type.dart';
import '../global_settings.dart';
import 'data_source.dart';

class DataMigration {
  init() async {
    await migration();
  }

  migration() async {
    bool updateApplication = Storage().get("version", "v0") != GlobalSettings().version;
    if (kDebugMode) {
      print("migration() current versionL ${GlobalSettings().version}; updateApplication = $updateApplication");
    }
    if (updateApplication) {
      if (kDebugMode) {
        print("migration() set new version = ${GlobalSettings().version}");
      }
      Storage().set("version", GlobalSettings().version);
    }
    await _sqlExecute([
      updateApplication ? "db/drop/2023-01-31.sql" : "",
      "db/migration/2023-01-29.sql",
    ]);
    await loadAssetsData();
    debugPrint("Migration complete");
  }

  Future<void> _sqlExecute(List<String> files) async {
    for (String file in files) {
      if (file.trim() == "") {
        continue;
      }
      if (kDebugMode) {
        print("Migration: $file");
      }
      String migration = await rootBundle.loadString("packages/rjdu/lib/assets/$file");
      List<String> split =
          migration.split(";"); //sqflite не умеет выполнять скрипт из нескольких запросов (как не странно)
      for (String query in split) {
        query = query.trim();
        if (query.isNotEmpty) {
          DataSource().db.execute(query);
        }
      }
    }
  }

  static Future<List<String>> loadTabData() async {
    List<String> result = [];
    Map assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    for (String path in assets.keys) {
      final regTab = RegExp(r'/tab[0-9]+\.json$');
      if (path.startsWith("assets/db/data/systemData/") && regTab.hasMatch(path)) {
        String fileData = await rootBundle.loadString(path);

        int? index = TypeParser.parseInt(path.split("assets/db/data/systemData/tab")[1].split(".json")[0]);
        if (index != null) {
          result.insert(index, fileData);
        }
      }
    }
    return result;
  }

  static Future<Map<String, String>> loadAssetByMask(String folder, String mask) async {
    Map<String, String> result = {};
    Map assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    for (String path in assets.keys) {
      final regTab = RegExp("$mask[a-zA-Z0-9]+\.json\$");
      if (path.startsWith("assets/db/data/$folder/") && regTab.hasMatch(path)) {
        String fileData = await rootBundle.loadString(path);

        String index = path.split("assets/db/data/$folder/$mask")[1].split(".json")[0];
        result[index] = fileData;
      }
    }
    return result;
  }

  Future<void> loadAssetsData() async {
    Map assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    for (String path in assets.keys) {
      if (path.startsWith("assets/db/data/")) {
        String fileData = await rootBundle.loadString(path);
        String fileName = path.split("/").last;
        DataSource().set(fileName, fileData, parseDataTypeFromDirectory(path), null, null, GlobalSettings().debug);
      }
    }
  }

  DataType parseDataTypeFromDirectory(String path) {
    List<DataType> values = DataType.values;
    for (DataType dataType in values) {
      if (path.contains("/${dataType.name}/")) {
        return dataType;
      }
    }
    return DataType.any;
  }
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rjdu/dynamic_ui/type_parser.dart';
import 'package:rjdu/storage.dart';
import '../data_type.dart';
import '../global_settings.dart';
import '../util.dart';
import 'data_source.dart';

class DataMigration {
  init() async {
    await migration();
  }

  migration() async {
    bool updateApplication = Storage().isUpdateApplication();
    Util.p("migration() current version: ${GlobalSettings().version}; updateApplication = $updateApplication");
    await _sqlExecute([
      updateApplication ? "db/drop/2023-01-31.sql" : "",
      "db/migration/2023-01-29.sql",
    ]);
    await loadAssetsData("packages/rjdu/lib/assets/db/data/");
    await loadAssetsData("assets/db/data/");
    Util.p("Migration complete");
  }

  Future<void> _sqlExecute(List<String> files) async {
    for (String file in files) {
      if (file.trim() == "") {
        continue;
      }
      Util.p("Migration: $file");
      String migration = await rootBundle.loadString("packages/rjdu/lib/assets/$file");
      //sqflite не умеет выполнять скрипт из нескольких запросов (как не странно)
      List<String> split = migration.split(";");
      for (String query in split) {
        query = query.trim();
        if (query.isNotEmpty) {
          DataSource().db.execute(query).onError((error, stackTrace) {
            Util.printStackTrace("DataMigration._sqlExecute()", error, stackTrace);
          });
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

  static Future<Map<String, String>> loadAssetByMask(String folder, String mask, [String preFolder = ""]) async {
    Map<String, String> result = {};
    Map assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    for (String path in assets.keys) {
      final regTab = RegExp("$mask[a-zA-Z0-9]+\.json\$");
      if (path.startsWith("${preFolder}assets/db/data/$folder/") && regTab.hasMatch(path)) {
        String fileData = await rootBundle.loadString(path);

        String index = path.split("${preFolder}assets/db/data/$folder/$mask")[1].split(".json")[0];
        result[index] = fileData;
      }
    }
    return result;
  }

  Future<void> loadAssetsData(String path) async {
    Map assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    List<String> list = [];

    for (String pathItem in assets.keys) {
      if (pathItem.startsWith(path)) {
        String fileData = await rootBundle.loadString(pathItem);
        String fileName = pathItem.split("/").last;
        list.add(fileName);
        DataSource().set(fileName, fileData, parseDataTypeFromDirectory(pathItem), null, null, GlobalSettings().debug);
      }
    }
    Util.p("DataMigration.loadAssetsData($path) $list");
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

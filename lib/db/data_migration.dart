import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data_type.dart';
import '../global_settings.dart';
import 'data_source.dart';

class DataMigration {
  init() async {
    await migration();
  }

  migration() async {
    await _sqlExecute([
      //GlobalSettings.debug ? 'db/drop/2023-01-31.sql' : '',
      'db/migration/2023-01-29.sql',
    ]);
    await loadAssetsData();
    debugPrint('Migration complete');
  }

  Future<void> _sqlExecute(List<String> files) async {
    for (String file in files) {
      if (file.trim() == '') {
        continue;
      }
      print("Migration: $file");
      String migration = await rootBundle.loadString('assets/$file');
      List<String> split = migration.split(";"); //sqflite не умеет выполнять скрипт из нескольких запросов (как не странно)
      for (String query in split) {
        query = query.trim();
        if (query.isNotEmpty) {
          //print("Q: $query");
          DataSource().db.execute(query);
        }
      }
    }
  }

  Future<void> loadAssetsData() async {
    Map assets = json.decode(await rootBundle.loadString('AssetManifest.json'));
    for (String path in assets.keys) {
      if (path.startsWith("assets/db/data/")) {
        String fileData = await rootBundle.loadString(path);
        String fileName = path.split("/").last;
        //print("loadAssetsData() $fileName");
        DataSource().set(fileName, fileData, parseDataTypeFromDirectory(path), null, null, GlobalSettings.debug);
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

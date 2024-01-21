import 'dart:convert';

import 'package:rjdu/data_type.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rjdu/util.dart';

import 'dynamic_ui/type_parser.dart';
import 'dynamic_ui/widget/abstract_widget_extension/iterator_theme/iterator_theme_loader.dart';
import 'dynamic_ui/widget/template_widget.dart';

class AssetsData {
  static final AssetsData _singleton = AssetsData._internal();

  factory AssetsData() {
    return _singleton;
  }

  AssetsData._internal();

  Map? assets;
  List<AssetsDataItem> list = [];

  init() async {
    assets = json.decode(await rootBundle.loadString("AssetManifest.json"));
    await loadAssetsData("packages/rjdu/lib/assets/db/data/");
    await loadAssetsData("assets/db/data/");
    getJsAutoImportSorted();

    //Сначала packages/rjdu/lib/, что бы можно было перекрыть проектными файлами
    Map<String, String> rjduIteratorTheme = await loadAssetByMask("systemData/iteratorTheme", "", "packages/rjdu/lib/");
    IteratorThemeLoader.load(rjduIteratorTheme, "rjdu");
    Map<String, String> rjduWidget = await loadAssetByMask("template/widget", "", "packages/rjdu/lib/");
    TemplateWidget.load(rjduWidget, "rjdu");

    Map<String, String> projectIteratorTheme = await loadAssetByMask("systemData/iteratorTheme", "IteratorTheme");
    IteratorThemeLoader.load(projectIteratorTheme, "project");
    Map<String, String> projectWidget = await loadAssetByMask("template/widget", "");
    TemplateWidget.load(projectWidget, "project");
  }

  Future<void> loadAssetsData(String path) async {
    for (String pathItem in assets!.keys) {
      if (pathItem.startsWith(path)) {
        DataType dataType = parseDataTypeFromDirectory(pathItem);
        String fileName = pathItem.split("/${dataType.name}/").last;
        list.add(AssetsDataItem(fileName, dataType, await getFileContent(pathItem)));
      }
    }
    Util.p("AssetsData.loadAssetsData($path) $list");
  }

  List<AssetsDataItem> getJsAutoImportSorted() {
    List<AssetsDataItem> result = [];
    List<String>? seqAiJson;
    for (AssetsDataItem assetsDataItem in list) {
      if (assetsDataItem.name == "seq.ai.json") {
        seqAiJson = Util.castListDynamicToString(json.decode(assetsDataItem.data));
        break;
      }
    }
    if (seqAiJson != null && seqAiJson.isNotEmpty) {
      for (String seqAiName in seqAiJson) {
        for (AssetsDataItem assetsDataItem in list) {
          if (assetsDataItem.name == seqAiName && assetsDataItem.type == DataType.js) {
            result.add(assetsDataItem);
            break;
          }
        }
      }
      for (AssetsDataItem assetsDataItem in list) {
        if (!seqAiJson.contains(assetsDataItem.name) &&
            assetsDataItem.name.endsWith("ai.js") &&
            assetsDataItem.type == DataType.js) {
          result.add(assetsDataItem);
        }
      }
    } else {
      for (AssetsDataItem assetsDataItem in list) {
        if (assetsDataItem.name.endsWith("ai.js") && assetsDataItem.type == DataType.js) {
          result.add(assetsDataItem);
        }
      }
    }
    return result;
  }

  Future<Map<String, String>> loadAssetByMask(String folder, String mask, [String preFolder = ""]) async {
    Map<String, String> result = {};
    for (String path in assets!.keys) {
      final regTab = RegExp("$mask[a-zA-Z0-9]+\.json\$");
      if (path.startsWith("${preFolder}assets/db/data/$folder/") && regTab.hasMatch(path)) {
        String fileName = path.split("${preFolder}assets/db/data/$folder/$mask")[1].split(".json")[0];
        result[fileName] = await getFileContent(path);
      }
    }
    return result;
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

  Future<List<String>> loadTabData() async {
    Map<int, String> unSort = {};
    for (String path in assets!.keys) {
      final regTab = RegExp(r'/tab[0-9]+\.json$');
      if (path.startsWith("assets/db/data/systemData/") && regTab.hasMatch(path)) {
        int? index = TypeParser.parseInt(path.split("assets/db/data/systemData/tab")[1].split(".json")[0]);
        if (index != null) {
          unSort[index] = await getFileContent(path);
        }
      }
    }
    List<String> result = [];
    List<int> sortedKeys = unSort.keys.toList()..sort();
    for (int key in sortedKeys) {
      result.add(unSort[key]!);
    }
    while (result.length < 2) {
      result.add(Util.jsonPretty(
        {
          "name": "main",
          "tab": {
            "flutterType": "BottomNavigationBarItem",
            "icon": {"flutterType": "Icon", "src": "not_interested"},
            "label": "???"
          },
          "content": {
            "flutterType": "Scaffold",
            "body": {
              "flutterType": "CustomScrollView",
              "onStateDataUpdate": true,
              "padding": "10,20,10,0",
              "appBar": {
                "flutterType": "SliverAppBar",
                "centerTitle": false,
                "title": {
                  "flutterType": "Text",
                  "label": "???",
                  "textAlign": "left",
                  "style": {"flutterType": "TextStyle", "fontSize": 17}
                },
              },
              "children": [
                {"flutterType": "Text", "label": "DataMigration not load 2tab data"}
              ]
            }
          }
        },
      ));
    }
    return result;
  }

  Future<String> getFileContent(String path) async {
    return await rootBundle.loadString(path);
  }
}

class AssetsDataItem {
  String name;
  DataType type;
  String data;

  AssetsDataItem(this.name, this.type, this.data);

  @override
  String toString() {
    return name;
  }
}

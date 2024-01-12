import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class SelectSheet extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String onPopJs = parsedJson["onPopJs"];
    String onPopSwitch = parsedJson["onPopSwitch"] ?? "onPop";
    String placeholder = parsedJson["placeholder"] ?? "Найти";
    bool extend = parsedJson["extend"] ?? false;
    return render({
      "flutterType": "InkWell",
      "onTap": {
        "sysInvoke": "NavigatorPush",
        "args": {
          "type": "bottomSheet",
          "height": 360,
          "link": {
            "template": extend ? "SelectSheetDataExtend.json" : "SelectSheetData.json",
          },
          "placeholder": placeholder,
          "onPop": {
            "jsInvoke": onPopJs,
            "args": {
              "includeAll": true,
              "switch": onPopSwitch,
            }
          },
          "constructor": {
            "jsInvoke": "SelectSheetData.js",
            "args": {
              "includeAll": true,
              "switch": "constructor",
              "listItem": parsedJson["children"],
            }
          }
        }
      },
      "child": {
        "flutterType": "Template",
        "src": "SelectSheet",
        "context": {
          "key": "SelectSheetGlobal",
          "data": {
            "label": "prev"
          }
        }
      }
    }, null, const Text("Error SelectSheet"), dynamicUIBuilderContext);
  }
}

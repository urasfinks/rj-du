import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class SelectSheet extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String placeholder = parsedJson["placeholder"] ?? "Найти";
    bool extend = parsedJson["extend"] ?? false;
    String stateKey = parsedJson["stateKey"];
    String defaultPlaceholder = parsedJson["defaultPlaceholder"] ?? "Выбрать из списка";
    String state = parsedJson["state"] ?? "main";
    int? selectedIndex = parsedJson["selectedIndex"];
    dynamicUIBuilderContext.dynamicPage.stateData.set(state, stateKey,
        selectedIndex == null ? {"label": defaultPlaceholder} : parsedJson["children"][selectedIndex], false);
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
            "jsInvoke": "SelectSheetData.js",
            "args": {"includeAll": true, "switch": "onFinish", "state": state, "stateKey": stateKey}
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
        "flutterType": "Container",
        "onStateDataUpdate": true,
        "onStateDataUpdateKey": state,
        "child": {
          "flutterType": "Template",
          "src": "SelectSheet",
          "context": {
            "key": "SelectSheet_${state}_$stateKey",
            "data": {
              "label": "\${state($state,$stateKey.label)}",
            }
          },
          "currentRenderTemplateList": ["context.data.label"]
        }
      }
    }, null, const Text("Error SelectSheet"), dynamicUIBuilderContext);
  }
}

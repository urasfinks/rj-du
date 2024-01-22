import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class SelectSheet extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String placeholder = parsedJson["placeholder"] ?? "Найти";

    String stateKey = parsedJson["stateKey"];
    String defaultPlaceholder = parsedJson["defaultPlaceholder"] ?? "Выбрать из списка";
    String state = parsedJson["state"] ?? "main";
    int? selectedIndex = parsedJson["selectedIndex"];
    List children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    Map<String, dynamic> selectedObject = {
      "label": defaultPlaceholder,
    };
    if (!dynamicUIBuilderContext.dynamicPage.stateData.contains(state, stateKey)) {
      if (selectedIndex != null && children.length > selectedIndex) {
        selectedObject = children[selectedIndex];
      }
      dynamicUIBuilderContext.dynamicPage.stateData.set(state, stateKey, selectedObject, false);
    }
    //Если кол-во элементов больше текущего значения, автоматически будет выбран шаблон с поисковиком
    int minCountItemForSearch = parsedJson["minCountItemForSearch"] ?? 4;

    String curTemplate = "SelectSheetData.json";
    if (parsedJson["extend"] ?? false) {
      curTemplate = "SelectSheetDataSearchExtend.json";
    } else if (children.length >= minCountItemForSearch) {
      curTemplate = "SelectSheetDataSearch.json";
    }
    return render({
      "flutterType": "InkWell",
      "onTap": {
        "sysInvoke": "NavigatorPush",
        "args": {
          "type": "bottomSheet",
          "height": 360,
          "link": {
            "template": curTemplate,
          },
          "placeholder": placeholder,
          "onPop": {
            "jsRouter": "SelectSheetData.ai.js",
            "args": {"method": "onFinish", "state": state, "stateKey": stateKey}
          },
          "constructor": {
            "jsRouter": "SelectSheetData.ai.js",
            "args": {
              "method": "constructor",
              "listItem": children,
            }
          }
        }
      },
      "child": {
        "flutterType": "Container",
        //"onStateDataUpdate": true,
        //"onStateDataUpdateKey": state,
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

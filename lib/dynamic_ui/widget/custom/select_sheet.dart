import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class SelectSheetWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    bool extend = parsedJson["extend"] ?? false;
    String stateKey = parsedJson["stateKey"];
    String state = parsedJson["state"] ?? "main";

    List children = updateList(parsedJson["children"] ?? [], dynamicUIBuilderContext);
    int selectedIndex = parsedJson["selectedIndex"] ?? -1;
    if (parsedJson.containsKey("selectedLabel")) {
      String selectedLabel = parsedJson["selectedLabel"];
      for (int i = 0; i < children.length; i++) {
        if (children[i]["label"] == selectedLabel) {
          selectedIndex = i;
          break;
        }
      }
    }
    String placeholder = parsedJson["placeholder"] ?? "Найти";
    if (children.isEmpty && extend) {
      placeholder = parsedJson["placeholderAdd"] ?? "Новое наименование";
    }
    String defaultLabel = parsedJson["defaultLabel"] ?? "Выбрать из списка";
    Map<String, dynamic> selectedObject = dynamicUIBuilderContext.dynamicPage.stateData.get(
        state,
        stateKey,
        {
          "label": defaultLabel,
          "_default": true,
        },
        true);
    if (selectedObject.containsKey("_default") && selectedIndex >= 0 && children.length > selectedIndex) {
      selectedObject = children[selectedIndex];
      dynamicUIBuilderContext.dynamicPage.stateData.set(state, stateKey, selectedObject, false);
    }

    //Если кол-во элементов больше текущего значения, автоматически будет выбран шаблон с поисковиком
    int minCountItemForSearch = parsedJson["minCountItemForSearch"] ?? 14;

    String curTemplate = "SelectSheetData.json";
    if (extend) {
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
            "args": {
              "method": "onFinish",
              "state": state,
              "stateKey": stateKey,
              "onNew": parsedJson["onNew"],
            }
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
          "compileTemplateList": ["context.data.label"]
        }
      }
    }, null, const Text("Error SelectSheet"), dynamicUIBuilderContext);
  }
}

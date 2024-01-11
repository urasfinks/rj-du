import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class SelectSheet extends AbstractWidget{
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return render({
      "flutterType": "InkWell",
      "onTap": {
        "sysInvoke": "NavigatorPush",
        "args": {
          "type": "bottomSheet",
          "height": 360,
          "link": {
            "template": "SelectSheetData.json",
          }
        }
      },
      "child": {
        "flutterType": "Template",
        "src": "SelectSheet"
      }
    }, null, const Text("Error SelectSheet"), dynamicUIBuilderContext);
  }

}
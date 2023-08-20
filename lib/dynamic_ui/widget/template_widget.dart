import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/util.dart';

class TemplateWidget extends AbstractWidget {
  static Map<String, Map> template = {};

  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> args = Util.templateArguments(Util.getMutableMap(parsedJson), dynamicUIBuilderContext);
    return render(Util.getMutableMap(template[args["src"]]), null, Text("Error render TemplateWidget: $args"),
        dynamicUIBuilderContext);
  }

  static void load(Map<String, String> map, String extra) {
    List<String> list = [];
    for (MapEntry<String, dynamic> item in map.entries) {
      try {
        list.add(item.key);
        Map<String, dynamic> parseTheme = json.decode(item.value);
        template[item.key] = parseTheme;
      } catch (e) {
        if (kDebugMode) {
          print("TemplateWidgetLoader exeption: $e");
        }
      }
    }
    if (kDebugMode) {
      print("TemplateWidget.load($extra) $list");
    }
  }
}

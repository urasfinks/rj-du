import 'dart:convert';

import 'package:rjdu/dynamic_ui/dynamic_ui.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/util.dart';

class TemplateWidget extends AbstractWidget {
  static Map<String, Map> template = {};

  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, "src", "", dynamicUIBuilderContext);
    Map<String, dynamic> templateMap = Util.getMutableMap(template[src]);
    dynamicUIBuilderContext = DynamicUI.changeContext(parsedJson, dynamicUIBuilderContext);
    return render(templateMap, null, Text("Error render TemplateWidget: $parsedJson"), dynamicUIBuilderContext);
  }

  static void load(Map<String, String> map, String extra) {
    List<String> list = [];
    for (MapEntry<String, dynamic> item in map.entries) {
      try {
        list.add(item.key);
        Map<String, dynamic> parseTheme = json.decode(item.value);
        template[item.key] = parseTheme;
      } catch (e) {
        Util.p("TemplateWidgetLoader exeption: $e");
      }
    }
    Util.p("TemplateWidget.load($extra) $list");
  }
}

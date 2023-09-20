import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class BorderProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Border.all(
      width: TypeParser.parseDouble(
        getValue(parsedJson, "width", 1, dynamicUIBuilderContext),
      )!,
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", "red", dynamicUIBuilderContext),
      )!,
      style: TypeParser.parseBorderStyle(
        getValue(parsedJson, "style", "solid", dynamicUIBuilderContext),
      )!,
      strokeAlign: TypeParser.parseDouble(
        getValue(parsedJson, "strokeAlign", 1, dynamicUIBuilderContext),
      )!,
    );
  }
}

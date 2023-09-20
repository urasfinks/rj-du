import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class BorderSideProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return BorderSide(
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", "red", dynamicUIBuilderContext),
      )!,
      width: TypeParser.parseDouble(
        getValue(parsedJson, "width", 1, dynamicUIBuilderContext),
      )!,
      style: TypeParser.parseBorderStyle(
        getValue(parsedJson, "style", "solid", dynamicUIBuilderContext),
      )!,
    );
  }
}

import '../../util.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class InkWellWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return InkWell(
      key: Util.getKey(),
      radius: TypeParser.parseDouble(
        getValue(parsedJson, "radius", null, dynamicUIBuilderContext),
      ),
      customBorder: render(
        parsedJson,
        "customBorder",
        null,
        dynamicUIBuilderContext,
      ),
      splashColor: TypeParser.parseColor(
        getValue(parsedJson, "splashColor", null, dynamicUIBuilderContext),
      ),
      highlightColor: TypeParser.parseColor(
        getValue(parsedJson, "highlightColor", null, dynamicUIBuilderContext),
      ),
      focusColor: TypeParser.parseColor(
        getValue(parsedJson, "focusColor", null, dynamicUIBuilderContext),
      ),
      hoverColor: TypeParser.parseColor(
        getValue(parsedJson, "hoverColor", null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
      onTap: () {
        click(parsedJson, dynamicUIBuilderContext, "onTap");
      },
    );
  }
}

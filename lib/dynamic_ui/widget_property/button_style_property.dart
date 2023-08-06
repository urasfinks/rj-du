import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class ButtonStyleProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        TypeParser.parseColor(
          getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
        ),
      ),
      shadowColor: MaterialStateProperty.all(
        TypeParser.parseColor(
          getValue(parsedJson, "shadowColor", "transparent", dynamicUIBuilderContext),
        ),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: TypeParser.parseBorderRadius(
            getValue(parsedJson, "borderRadius", null, dynamicUIBuilderContext),
          )!,
        ),
      ),
    );
  }
}

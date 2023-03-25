import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class LinearGradientProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return LinearGradient(
      begin: TypeParser.parseAlignment(
        getValue(parsedJson, 'begin', 'centerLeft', dynamicUIBuilderContext),
      )!,
      end: TypeParser.parseAlignment(
        getValue(parsedJson, 'end', 'centerRight', dynamicUIBuilderContext),
      )!,
      stops: TypeParser.parseListDouble(
        getValue(parsedJson, 'stops', null, dynamicUIBuilderContext),
      ),
      colors: TypeParser.parseListColor(
        getValue(parsedJson, 'colors', null, dynamicUIBuilderContext),
      ),
    );
  }
}

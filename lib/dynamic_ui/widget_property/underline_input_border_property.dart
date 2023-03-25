import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../type_parser.dart';

class UnderlineInputBorderProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return UnderlineInputBorder(
      borderSide: render(parsedJson, 'borderSide', const BorderSide(), dynamicUIBuilderContext),
      borderRadius: TypeParser.parseBorderRadius(
        getValue(parsedJson, 'borderRadius', 4.0, dynamicUIBuilderContext),
      )!,
    );
  }
}

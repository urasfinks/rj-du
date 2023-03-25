import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class BoxConstraintsProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return BoxConstraints(
      maxHeight: TypeParser.parseDouble(
            getValue(parsedJson, 'maxHeight', null, dynamicUIBuilderContext),
          ) ??
          double.infinity,
      minHeight: TypeParser.parseDouble(
            getValue(parsedJson, 'minHeight', null, dynamicUIBuilderContext),
          ) ??
          0,
      maxWidth: TypeParser.parseDouble(
            getValue(parsedJson, 'maxWidth', null, dynamicUIBuilderContext),
          ) ??
          double.infinity,
      minWidth: TypeParser.parseDouble(
            getValue(parsedJson, 'minHeight', null, dynamicUIBuilderContext),
          ) ??
          0,
    );
  }
}

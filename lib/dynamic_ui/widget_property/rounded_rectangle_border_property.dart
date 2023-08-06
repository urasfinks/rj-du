import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class RoundedRectangleBorderProperty extends AbstractWidget{
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return RoundedRectangleBorder(
      borderRadius: TypeParser.parseBorderRadius(
        getValue(parsedJson, "borderRadius", 0, dynamicUIBuilderContext),
      )!,
    );
  }
  
}
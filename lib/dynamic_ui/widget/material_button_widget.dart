import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../type_parser.dart';
import 'abstract_widget.dart';

class MaterialButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    return MaterialButton(
      shape: render(parsedJson, 'shape', null, dynamicUIBuilderContext),
      height: TypeParser.parseDouble(
        getValue(parsedJson, 'height', null, dynamicUIBuilderContext),
      ),
      minWidth: TypeParser.parseDouble(
        getValue(parsedJson, 'minWidth', null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, 'elevation', 0, dynamicUIBuilderContext),
      )!,
      textColor: TypeParser.parseColor(
        getValue(parsedJson, 'textColor', null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, 'color', null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
      onPressed: () {
        click(parsedJson, dynamicUIBuilderContext);
      },
      splashColor: TypeParser.parseColor(
        getValue(parsedJson, 'splashColor', null, dynamicUIBuilderContext),
      ),
    );
  }
}

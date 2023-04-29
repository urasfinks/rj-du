import 'package:flutter/material.dart';
import '../../util.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class MaterialWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Material(
      type: TypeParser.parseMaterialType(
          getValue(parsedJson, 'type', 'canvas', dynamicUIBuilderContext)
      )!,
      key: Util.getKey(),
      borderRadius: TypeParser.parseBorderRadius(
        getValue(parsedJson, 'borderRadius', null, dynamicUIBuilderContext),
      ),
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, 'clipBehavior', 'none', dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
      color: TypeParser.parseColor(
        getValue(parsedJson, 'color', null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, 'elevation', 0, dynamicUIBuilderContext),
      )!,
      shadowColor: TypeParser.parseColor(
        getValue(parsedJson, 'shadowColor', null, dynamicUIBuilderContext),
      ),
      textStyle: render(parsedJson, 'textStyle', null, dynamicUIBuilderContext),
    );
  }
}

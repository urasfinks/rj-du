import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';
import 'package:flutter/material.dart';

class PositionedWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Positioned(
      key: Util.getKey(),
      height: TypeParser.parseDouble(
        getValue(parsedJson, 'height', null, dynamicUIBuilderContext),
      ),
      width: TypeParser.parseDouble(
        getValue(parsedJson, 'width', null, dynamicUIBuilderContext),
      ),
      left: TypeParser.parseDouble(
        getValue(parsedJson, 'left', null, dynamicUIBuilderContext),
      ),
      right: TypeParser.parseDouble(
        getValue(parsedJson, 'right', null, dynamicUIBuilderContext),
      ),
      top: TypeParser.parseDouble(
        getValue(parsedJson, 'top', null, dynamicUIBuilderContext),
      ),
      bottom: TypeParser.parseDouble(
        getValue(parsedJson, 'bottom', null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}

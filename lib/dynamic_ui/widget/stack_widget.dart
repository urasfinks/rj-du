import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class StackWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Stack(
      key: Util.getKey(),
      alignment: TypeParser.parseAlignmentDirectional(
        getValue(parsedJson, "alignment", "topStart", dynamicUIBuilderContext),
      )!,
      textDirection: TypeParser.parseTextDirection(
        getValue(parsedJson, "textDirection", null, dynamicUIBuilderContext),
      ),
      fit: TypeParser.parseStackFit(
        getValue(parsedJson, "fit", "loose", dynamicUIBuilderContext),
      )!,
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, "clipBehavior", "hardEdge", dynamicUIBuilderContext),
      )!,
      children: renderList(parsedJson, "children", dynamicUIBuilderContext),
    );
  }
}

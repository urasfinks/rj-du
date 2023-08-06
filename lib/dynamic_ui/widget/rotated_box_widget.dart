import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class RotatedBoxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return RotatedBox(
      key: Util.getKey(),
      quarterTurns: TypeParser.parseInt(
        getValue(parsedJson, "quarterTurns", 0, dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
    );
  }
}

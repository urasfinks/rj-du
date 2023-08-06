import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class LimitedBoxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return LimitedBox(
      key: Util.getKey(),
      maxWidth: TypeParser.parseDouble(
        getValue(parsedJson, "maxWidth", "infinity", dynamicUIBuilderContext),
      )!,
      maxHeight: TypeParser.parseDouble(
        getValue(parsedJson, "maxWidth", "infinity", dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
    );
  }
}

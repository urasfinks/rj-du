import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class OpacityWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Opacity(
      key: Util.getKey(),
      opacity: TypeParser.parseDouble(
        getValue(parsedJson, "opacity", 1.0, dynamicUIBuilderContext) ?? 1.0,
      )!,
      alwaysIncludeSemantics: TypeParser.parseBool(
        getValue(parsedJson, "alwaysIncludeSemantics", false, dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
    );
  }
}

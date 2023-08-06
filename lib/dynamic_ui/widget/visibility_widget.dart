import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class VisibilityWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Visibility(
      key: Util.getKey(),
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
      visible: TypeParser.parseBool(
        getValue(parsedJson, "visible", true, dynamicUIBuilderContext),
      ) ?? true,
      maintainAnimation: TypeParser.parseBool(
        getValue(parsedJson, "maintainAnimation", false, dynamicUIBuilderContext),
      )!,
      maintainInteractivity: TypeParser.parseBool(
        getValue(parsedJson, "maintainInteractivity", false, dynamicUIBuilderContext),
      ) ?? false,
      maintainSemantics: TypeParser.parseBool(
        getValue(parsedJson, "maintainSemantics", false, dynamicUIBuilderContext),
      ) ?? false,
      maintainSize: TypeParser.parseBool(
        getValue(parsedJson, "maintainSize", false, dynamicUIBuilderContext),
      ) ?? false,
      maintainState: TypeParser.parseBool(
        getValue(parsedJson, "maintainState", false, dynamicUIBuilderContext),
      ) ?? false,
      replacement: render(parsedJson, "replacement", const SizedBox.shrink(), dynamicUIBuilderContext),
    );
  }
}

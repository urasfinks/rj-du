import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../util.dart';
import '../type_parser.dart';

class SafeAreaWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SafeArea(
      key: Util.getKey(),
      left: TypeParser.parseBool(
        getValue(parsedJson, "left", true, dynamicUIBuilderContext),
      )!,
      top: TypeParser.parseBool(
        getValue(parsedJson, "top", true, dynamicUIBuilderContext),
      )!,
      right: TypeParser.parseBool(
        getValue(parsedJson, "right", true, dynamicUIBuilderContext),
      )!,
      bottom: TypeParser.parseBool(
        getValue(parsedJson, "bottom", true, dynamicUIBuilderContext),
      )!,
      maintainBottomViewPadding: TypeParser.parseBool(
        getValue(parsedJson, "maintainBottomViewPadding", false, dynamicUIBuilderContext),
      )!,
      minimum: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "minimum", EdgeInsets.zero, dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, "child", const SizedBox(), dynamicUIBuilderContext),
    );
  }
}

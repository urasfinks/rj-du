import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import 'abstract_widget.dart';

class SliverFillRemainingWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SliverFillRemaining(
      hasScrollBody: TypeParser.parseBool(
        getValue(parsedJson, "hasScrollBody", false, dynamicUIBuilderContext),
      )!,
      fillOverscroll: TypeParser.parseBool(
        getValue(parsedJson, "fillOverscroll", true, dynamicUIBuilderContext),
      )!,
      child: render(
          parsedJson,
          "child",
          const SizedBox(),
          dynamicUIBuilderContext),
    );
  }
}

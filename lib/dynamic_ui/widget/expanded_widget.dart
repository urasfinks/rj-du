import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class ExpandedWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Expanded(
      key: Util.getKey(),
      flex: TypeParser.parseInt(
        getValue(parsedJson, "flex", 1, dynamicUIBuilderContext),
      )!,
      child: render(
        parsedJson,
        "child",
        const SizedBox(),
        dynamicUIBuilderContext,
      ),
    );
  }
}

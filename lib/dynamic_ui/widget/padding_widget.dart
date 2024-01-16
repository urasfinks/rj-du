import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class PaddingWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Padding(
      key: Util.getKey(),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
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

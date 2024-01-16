import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter_margin_widget/flutter_margin_widget.dart';
import '../../util.dart';
import 'package:flutter/material.dart';

class MarginWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Margin(
      key: Util.getKey(),
      margin: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "margin", null, dynamicUIBuilderContext),
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

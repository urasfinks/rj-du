import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class ColumnWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Column(
      key: Util.getKey(),
      mainAxisSize: TypeParser.parseMainAxisSize(
        getValue(parsedJson, "mainAxisSize", "min", dynamicUIBuilderContext),
      )!,
      crossAxisAlignment: TypeParser.parseCrossAxisAlignment(
        getValue(parsedJson, "crossAxisAlignment", "center", dynamicUIBuilderContext),
      )!,
      mainAxisAlignment: TypeParser.parseMainAxisAlignment(
        getValue(parsedJson, "mainAxisAlignment", "start", dynamicUIBuilderContext),
      )!,
      children: renderList(parsedJson, "children", dynamicUIBuilderContext),
    );
  }
}

import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class RowWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Row(
      key: Util.getKey(),
      crossAxisAlignment: TypeParser.parseCrossAxisAlignment(
        getValue(parsedJson, 'crossAxisAlignment', 'center', dynamicUIBuilderContext),
      )!,
      mainAxisAlignment: TypeParser.parseMainAxisAlignment(
        getValue(parsedJson, 'mainAxisAlignment', 'start', dynamicUIBuilderContext),
      )!,
      children: renderList(parsedJson, 'children', dynamicUIBuilderContext),
    );
  }
}

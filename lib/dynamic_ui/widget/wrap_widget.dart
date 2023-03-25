import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class WrapWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Wrap(
      key: Util.getKey(),
      direction: TypeParser.parseAxis(
        getValue(parsedJson, 'direction', 1.0, dynamicUIBuilderContext),
      )!,
      alignment: TypeParser.parseWrapAlignment(
        getValue(parsedJson, 'alignment', 'start', dynamicUIBuilderContext),
      )!,
      spacing: TypeParser.parseDouble(
        getValue(parsedJson, 'spacing', 0.0, dynamicUIBuilderContext),
      )!,
      runAlignment: TypeParser.parseWrapAlignment(
        getValue(parsedJson, 'runAlignment', 'start', dynamicUIBuilderContext),
      )!,
      runSpacing: TypeParser.parseDouble(
        getValue(parsedJson, 'runSpacing', 0.0, dynamicUIBuilderContext),
      )!,
      crossAxisAlignment: TypeParser.parseWrapCrossAlignment(
        getValue(parsedJson, 'crossAxisAlignment', 'start', dynamicUIBuilderContext),
      )!,
      textDirection: TypeParser.parseTextDirection(
        getValue(parsedJson, 'textDirection', null, dynamicUIBuilderContext),
      ),
      verticalDirection: TypeParser.parseVerticalDirection(
        getValue(parsedJson, 'verticalDirection', 'down', dynamicUIBuilderContext),
      )!,
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, 'clipBehavior', 'none', dynamicUIBuilderContext),
      )!,
      children: renderList(parsedJson, 'children', dynamicUIBuilderContext),
    );
  }
}

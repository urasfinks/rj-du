import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class GridViewWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return GridView.count(

      key: Util.getKey(),
      crossAxisCount: TypeParser.parseInt(
        getValue(parsedJson, 'crossAxisCount', 1, dynamicUIBuilderContext),
      )!,
      mainAxisSpacing: TypeParser.parseDouble(
        getValue(parsedJson, 'mainAxisSpacing', 0.0, dynamicUIBuilderContext),
      )!,
      crossAxisSpacing: TypeParser.parseDouble(
        getValue(parsedJson, 'crossAxisSpacing', 0.0, dynamicUIBuilderContext),
      )!,
      childAspectRatio: TypeParser.parseDouble(
        getValue(parsedJson, 'childAspectRatio', 1.0, dynamicUIBuilderContext),
      )!,
      reverse: TypeParser.parseBool(
        getValue(parsedJson, 'reverse', false, dynamicUIBuilderContext),
      )!,
      scrollDirection: TypeParser.parseAxis(
        getValue(parsedJson, 'scrollDirection', 'vertical', dynamicUIBuilderContext)!,
      )!,
      shrinkWrap: TypeParser.parseBool(
        getValue(parsedJson, 'shrinkWrap', false, dynamicUIBuilderContext),
      )!,
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'padding', null, dynamicUIBuilderContext),
      ),
      physics: Util.getPhysics(),
      children: renderList(parsedJson, 'children', dynamicUIBuilderContext),
    );
  }
}

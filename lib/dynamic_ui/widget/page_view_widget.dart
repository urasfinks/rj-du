import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class PageViewWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return PageView(
      key: Util.getKey(),
      scrollDirection: TypeParser.parseAxis(
        getValue(parsedJson, 'scrollDirection', 'vertical', dynamicUIBuilderContext)!,
      )!,
      reverse: TypeParser.parseBool(
        getValue(parsedJson, 'reverse', false, dynamicUIBuilderContext),
      )!,
      physics: Util.getPhysics(),
      pageSnapping: TypeParser.parseBool(
        getValue(parsedJson, 'pageSnapping', true, dynamicUIBuilderContext),
      )!,
      padEnds: TypeParser.parseBool(
        getValue(parsedJson, 'padEnds', true, dynamicUIBuilderContext),
      )!,
      allowImplicitScrolling: TypeParser.parseBool(
        getValue(parsedJson, 'allowImplicitScrolling', false, dynamicUIBuilderContext),
      )!,
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, 'clipBehavior', 'none', dynamicUIBuilderContext),
      )!,
      children: renderList(parsedJson, 'children', dynamicUIBuilderContext),
    );
  }
}

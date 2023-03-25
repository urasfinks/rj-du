import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class FittedBoxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return FittedBox(
      key: Util.getKey(),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, 'fit', 'contain', dynamicUIBuilderContext),
      )!,
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', 'center', dynamicUIBuilderContext),
      )!,
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, 'clipBehavior', 'none', dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}

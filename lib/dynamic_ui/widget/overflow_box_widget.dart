import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class OverflowBoxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return OverflowBox(
      key: Util.getKey(),
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', 'center', dynamicUIBuilderContext),
      )!,
      minWidth: TypeParser.parseDouble(
        getValue(parsedJson, 'minWidth', null, dynamicUIBuilderContext),
      ),
      maxWidth: TypeParser.parseDouble(
        getValue(parsedJson, 'maxWidth', null, dynamicUIBuilderContext),
      ),
      minHeight: TypeParser.parseDouble(
        getValue(parsedJson, 'minHeight', null, dynamicUIBuilderContext),
      ),
      maxHeight: TypeParser.parseDouble(
        getValue(parsedJson, 'maxHeight', null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}

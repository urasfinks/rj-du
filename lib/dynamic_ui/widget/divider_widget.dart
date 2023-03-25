import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class DividerWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Divider(
      key: Util.getKey(),
      height: TypeParser.parseDouble(
        getValue(parsedJson, 'height', null, dynamicUIBuilderContext),
      ),
      thickness: TypeParser.parseDouble(
        getValue(parsedJson, 'thickness', null, dynamicUIBuilderContext),
      ),
      endIndent: TypeParser.parseDouble(
        getValue(parsedJson, 'endIndent', null, dynamicUIBuilderContext),
      ),
      indent: TypeParser.parseDouble(
        getValue(parsedJson, 'indent', null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, 'color', null, dynamicUIBuilderContext),
      ),
    );
  }
}

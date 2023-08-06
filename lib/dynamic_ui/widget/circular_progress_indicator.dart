import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class CircularProgressIndicatorWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return CircularProgressIndicator(
      key: Util.getKey(),
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
    );
  }
}

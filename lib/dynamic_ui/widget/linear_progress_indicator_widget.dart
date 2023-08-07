import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';

import '../../util.dart';
import '../type_parser.dart';

class LinearProgressIndicatorWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return LinearProgressIndicator(
      key: Util.getKey(),
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
      minHeight: TypeParser.parseDouble(
        getValue(parsedJson, "minHeight", null, dynamicUIBuilderContext),
      ),
      semanticsLabel: getValue(parsedJson, "semanticsLabel", null, dynamicUIBuilderContext),
      semanticsValue: getValue(parsedJson, "semanticsValue", null, dynamicUIBuilderContext),
      value: TypeParser.parseDouble(
        getValue(parsedJson, "value", null, dynamicUIBuilderContext),
      ),
    );
  }
}

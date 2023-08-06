import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class BaselineWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Baseline(
      key: Util.getKey(),
      baseline: TypeParser.parseDouble(
        getValue(parsedJson, "baseline", null, dynamicUIBuilderContext),
      )!,
      baselineType: TypeParser.parseTextBaseline(
        getValue(parsedJson, "baselineType", null, dynamicUIBuilderContext),
      )!,
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
    );
  }
}

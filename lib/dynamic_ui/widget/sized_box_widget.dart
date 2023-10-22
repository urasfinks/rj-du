import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class SizedBoxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (parsedJson["type"] ?? "default") {
      case "expand":
        return SizedBox.expand(
          key: Util.getKey(),
          child: render(parsedJson, "child", null, dynamicUIBuilderContext),
        );
      default:
        return SizedBox(
          key: Util.getKey(),
          width: TypeParser.parseDouble(
            getValue(parsedJson, "width", null, dynamicUIBuilderContext),
          ),
          height: TypeParser.parseDouble(
            getValue(parsedJson, "height", null, dynamicUIBuilderContext),
          ),
          child: render(parsedJson, "child", null, dynamicUIBuilderContext),
        );
    }
  }
}

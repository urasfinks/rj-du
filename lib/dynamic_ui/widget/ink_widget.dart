import '../../util.dart';
import '../dynamic_ui.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class InkWidget extends AbstractWidget{
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Ink(
      key: Util.getKey(),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
      ),
      width: TypeParser.parseDouble(
        getValue(parsedJson, "width", null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        getValue(parsedJson, "height", null, dynamicUIBuilderContext),
      ),
      decoration: render(parsedJson, "decoration", null, dynamicUIBuilderContext),
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
      child: render(
        parsedJson,
        "child",
        DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
        dynamicUIBuilderContext,
      ),
    );
  }

}
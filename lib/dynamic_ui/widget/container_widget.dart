import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class ContainerWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Container(
      key: Util.getKey(),
      margin: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "margin", null, dynamicUIBuilderContext),
      ),
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
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, "alignment", null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, "clipBehavior", "none", dynamicUIBuilderContext),
      )!,
      child: render(
        parsedJson,
        "child",
        const SizedBox(),
        dynamicUIBuilderContext,
      ),
    );
  }
}

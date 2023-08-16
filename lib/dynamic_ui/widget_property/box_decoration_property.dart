import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class BoxDecorationProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return BoxDecoration(
      shape: TypeParser.parseBoxShape(
        getValue(parsedJson, "shape", "rectangle", dynamicUIBuilderContext),
      )!,
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
      image: render(parsedJson, "image", null, dynamicUIBuilderContext),
      borderRadius: TypeParser.parseBorderRadius(
        getValue(parsedJson, "borderRadius", null, dynamicUIBuilderContext),
      ),
      gradient: getValue(parsedJson, "gradient", null, dynamicUIBuilderContext),
      border: render(parsedJson, "border", null, dynamicUIBuilderContext),
    );
  }
}

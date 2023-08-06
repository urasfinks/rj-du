import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class InputDecorationProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return InputDecoration(
      suffixIconConstraints: render(parsedJson, "suffixIconConstraints", null, dynamicUIBuilderContext),
      suffixIcon: render(parsedJson, "suffixIcon", null, dynamicUIBuilderContext),
      enabledBorder: render(parsedJson, "enabledBorder", null, dynamicUIBuilderContext),
      focusedBorder: render(parsedJson, "focusedBorder", null, dynamicUIBuilderContext),
      filled: TypeParser.parseBool(
        getValue(parsedJson, "filled", null, dynamicUIBuilderContext),
      ),
      fillColor: TypeParser.parseColor(
        getValue(parsedJson, "fillColor", null, dynamicUIBuilderContext),
      ),
      icon: render(parsedJson, "icon", null, dynamicUIBuilderContext),
      border: render(parsedJson, "border", null, dynamicUIBuilderContext),
      labelText: getValue(parsedJson, "labelText", null, dynamicUIBuilderContext),
      errorText: getValue(parsedJson, "errorText", null, dynamicUIBuilderContext),
      hintText: getValue(parsedJson, "hintText", null, dynamicUIBuilderContext),
      contentPadding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "contentPadding", null, dynamicUIBuilderContext),
      ),
      prefixIcon: render(parsedJson, "prefixIcon", null, dynamicUIBuilderContext),
      isDense: true,
    );
  }
}

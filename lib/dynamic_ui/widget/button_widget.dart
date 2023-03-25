import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class ButtonWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return RawMaterialButton(
      key: Util.getKey(),
      fillColor: TypeParser.parseColor(
        getValue(parsedJson, 'fillColor', null, dynamicUIBuilderContext),
      ),
      focusColor: TypeParser.parseColor(
        getValue(parsedJson, 'focusColor', null, dynamicUIBuilderContext),
      ),
      hoverColor: TypeParser.parseColor(
        getValue(parsedJson, 'hoverColor', null, dynamicUIBuilderContext),
      ),
      splashColor: TypeParser.parseColor(
        getValue(parsedJson, 'splashColor', null, dynamicUIBuilderContext),
      ),
      highlightColor: TypeParser.parseColor(
        getValue(parsedJson, 'highlightColor', null, dynamicUIBuilderContext),
      ),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'padding', 0, dynamicUIBuilderContext),
      )!,
      elevation: 0,
      constraints: BoxConstraints(
        minWidth: TypeParser.parseDouble(
          getValue(parsedJson, 'minWidth', 0.0, dynamicUIBuilderContext),
        )!,
        maxWidth: TypeParser.parseDouble(
          getValue(parsedJson, 'maxWidth', "infinity", dynamicUIBuilderContext),
        )!,
        minHeight: TypeParser.parseDouble(
          getValue(parsedJson, 'minHeight', 0.0, dynamicUIBuilderContext),
        )!,
        maxHeight: TypeParser.parseDouble(
          getValue(parsedJson, 'maxHeight', "infinity", dynamicUIBuilderContext),
        )!,
      ),
      onPressed: () {
        click(parsedJson, dynamicUIBuilderContext);
      },
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
      shape: const CircleBorder(),
    );
  }
}

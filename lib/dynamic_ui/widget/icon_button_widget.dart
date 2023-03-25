import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class IconButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return IconButton(
      key: Util.getKey(),
      icon: render(parsedJson, 'icon', null, dynamicUIBuilderContext),
      iconSize: TypeParser.parseDouble(
        getValue(parsedJson, 'iconSize', null, dynamicUIBuilderContext),
      ),
      splashRadius: TypeParser.parseDouble(
        getValue(parsedJson, 'splashRadius', null, dynamicUIBuilderContext),
      ),
      color: TypeParser.parseColor(
        getValue(parsedJson, 'color', null, dynamicUIBuilderContext),
      ),
      focusColor: TypeParser.parseColor(
        getValue(parsedJson, 'focusColor', null, dynamicUIBuilderContext),
      ),
      hoverColor: TypeParser.parseColor(
        getValue(parsedJson, 'hoverColor', null, dynamicUIBuilderContext),
      ),
      highlightColor: TypeParser.parseColor(
        getValue(parsedJson, 'highlightColor', null, dynamicUIBuilderContext),
      ),
      splashColor: TypeParser.parseColor(
        getValue(parsedJson, 'splashColor', null, dynamicUIBuilderContext),
      ),
      disabledColor: TypeParser.parseColor(
        getValue(parsedJson, 'disabledColor', null, dynamicUIBuilderContext),
      ),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'padding', null, dynamicUIBuilderContext),
      ),
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', 'center', dynamicUIBuilderContext),
      )!,
      tooltip: getValue(parsedJson, 'tooltip', null, dynamicUIBuilderContext),
      autofocus: TypeParser.parseBool(
        getValue(parsedJson, 'autofocus', false, dynamicUIBuilderContext),
      )!,
      enableFeedback: TypeParser.parseBool(
        getValue(parsedJson, 'enableFeedback', true, dynamicUIBuilderContext),
      )!,
      onPressed: () {
        click(parsedJson, dynamicUIBuilderContext);
      },
    );
  }
}

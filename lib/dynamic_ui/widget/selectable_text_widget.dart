import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class SelectableTextWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SelectableText(
      getValue(parsedJson, 'label', '', dynamicUIBuilderContext),
      key: Util.getKey(),
      style: render(parsedJson, 'style', null, dynamicUIBuilderContext),
      textAlign: TypeParser.parseTextAlign(
        getValue(parsedJson, 'textAlign', 'start', dynamicUIBuilderContext),
      )!,
      textDirection: TypeParser.parseTextDirection(
        getValue(parsedJson, 'textDirection', null, dynamicUIBuilderContext),
      ),
      textScaleFactor: TypeParser.parseDouble(
        getValue(parsedJson, 'textScaleFactor', null, dynamicUIBuilderContext),
      ),
      showCursor: getValue(parsedJson, 'showCursor', false, dynamicUIBuilderContext),
      autofocus: TypeParser.parseBool(
        getValue(parsedJson, 'autofocus', false, dynamicUIBuilderContext),
      )!,
      minLines: TypeParser.parseInt(
        getValue(parsedJson, 'minLines', 1, dynamicUIBuilderContext),
      ),
      maxLines: TypeParser.parseInt(
        getValue(parsedJson, 'maxLines', 1, dynamicUIBuilderContext),
      ),
      cursorColor: TypeParser.parseColor(
        getValue(parsedJson, 'cursorColor', null, dynamicUIBuilderContext),
      ),
      enableInteractiveSelection: TypeParser.parseBool(
        getValue(parsedJson, 'enableInteractiveSelection', true, dynamicUIBuilderContext),
      )!,
      textWidthBasis: TypeParser.parseTextWidthBasis(
        getValue(parsedJson, 'textWidthBasis', null, dynamicUIBuilderContext),
      ),
      scrollPhysics: Util.getPhysics(),
    );
  }
}

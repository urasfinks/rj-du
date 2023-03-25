import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class TextWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Text(
      getValue(parsedJson, 'label', '', dynamicUIBuilderContext).toString(),
      key: Util.getKey(),
      textDirection: TypeParser.parseTextDirection(
        getValue(parsedJson, 'textDirection', null, dynamicUIBuilderContext),
      ),
      textAlign: TypeParser.parseTextAlign(
        getValue(parsedJson, 'textAlign', null, dynamicUIBuilderContext),
      ),
      softWrap: getValue(parsedJson, 'softWrap', null, dynamicUIBuilderContext),
      overflow: TypeParser.parseTextOverflow(
        getValue(parsedJson, 'overflow', null, dynamicUIBuilderContext),
      ),
      style: render(parsedJson, 'style', const TextStyle(fontSize: 15), dynamicUIBuilderContext),
      textScaleFactor: TypeParser.parseDouble(
        getValue(parsedJson, 'textScaleFactor', null, dynamicUIBuilderContext),
      ),
      maxLines: TypeParser.parseInt(
        getValue(parsedJson, 'maxLines', null, dynamicUIBuilderContext),
      ),
      textWidthBasis: TypeParser.parseTextWidthBasis(
        getValue(parsedJson, 'textWidthBasis', null, dynamicUIBuilderContext),
      ),
    );
  }
}

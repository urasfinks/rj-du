import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class DecorationImageProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return DecorationImage(
      image: getValue(parsedJson, 'image', null, dynamicUIBuilderContext),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, 'fit', null, dynamicUIBuilderContext),
      ),
      scale: TypeParser.parseDouble(
        getValue(parsedJson, 'scale', 1.0, dynamicUIBuilderContext),
      )!,
      opacity: TypeParser.parseDouble(
        getValue(parsedJson, 'opacity', 1.0, dynamicUIBuilderContext),
      )!,
      repeat: TypeParser.parseImageRepeat(
        getValue(parsedJson, 'repeat', "noRepeat", dynamicUIBuilderContext),
      )!,
      filterQuality: FilterQuality.high,
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', "center", dynamicUIBuilderContext),
      )!,
      matchTextDirection: TypeParser.parseBool(
        getValue(parsedJson, 'matchTextDirection', false, dynamicUIBuilderContext),
      )!,
    );
  }
}

import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class ImageNetworkWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, 'src', null, dynamicUIBuilderContext);
    if (!src.startsWith("http")) {
      src = "${GlobalSettings.host}$src";
    }
    return Image.network(
      src,
      key: Util.getKey(),
      width: TypeParser.parseDouble(
        getValue(parsedJson, 'width', null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        getValue(parsedJson, 'height', null, dynamicUIBuilderContext),
      ),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, 'fit', null, dynamicUIBuilderContext),
      ),
      scale: TypeParser.parseDouble(
        getValue(parsedJson, 'scale', 1.0, dynamicUIBuilderContext),
      )!,
      repeat: TypeParser.parseImageRepeat(
        getValue(parsedJson, 'repeat', "noRepeat", dynamicUIBuilderContext),
      )!,
      filterQuality: FilterQuality.high,
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', "center", dynamicUIBuilderContext),
      )!,
    );
  }
}

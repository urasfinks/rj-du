import 'package:cached_network_image/cached_network_image.dart';
import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class ImageNetworkCachedWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, "src", null, dynamicUIBuilderContext);
    if (!src.startsWith("http")) {
      src = "${GlobalSettings().host}$src";
    }
    return CachedNetworkImage(
      color: TypeParser.parseColor(
        getValue(parsedJson, "color", null, dynamicUIBuilderContext),
      ),
      imageUrl: src,
      //placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, "fit", null, dynamicUIBuilderContext),
      ),
      width: TypeParser.parseDouble(
        getValue(parsedJson, "width", null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        getValue(parsedJson, "height", null, dynamicUIBuilderContext),
      ),
      repeat: TypeParser.parseImageRepeat(
        getValue(parsedJson, "repeat", "noRepeat", dynamicUIBuilderContext),
      )!,
      filterQuality: FilterQuality.high,
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, "alignment", "center", dynamicUIBuilderContext),
      )!,
    );
  }
}

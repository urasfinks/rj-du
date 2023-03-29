import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../global_settings.dart';

class ImageNetworkProviderProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, 'src', null, dynamicUIBuilderContext);
    if (!src.startsWith("http")) {
      src = "${GlobalSettings().host}$src";
    }
    return NetworkImage(src);
  }
}

import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class AssetImageWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return AssetImage(
      getValue(parsedJson, 'src', '', dynamicUIBuilderContext),
    );
  }
}

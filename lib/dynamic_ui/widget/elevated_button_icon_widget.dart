import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class ElevatedButtonIconWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return ElevatedButton.icon(
      key: Util.getKey(),
      onPressed: () {
        click(parsedJson, dynamicUIBuilderContext);
      },
      style: render(parsedJson, 'style', null, dynamicUIBuilderContext),
      icon: render(parsedJson, 'icon', null, dynamicUIBuilderContext),
      label: getValue(parsedJson, 'label', null, dynamicUIBuilderContext),
    );
  }
}

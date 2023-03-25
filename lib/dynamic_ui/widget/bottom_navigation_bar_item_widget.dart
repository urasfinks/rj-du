import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarItemWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return BottomNavigationBarItem(
      icon: render(parsedJson, 'icon', null, dynamicUIBuilderContext),
      label: getValue(parsedJson, 'label', '', dynamicUIBuilderContext),
    );
  }
}

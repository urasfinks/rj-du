import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class ScrollbarWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (!dynamicUIBuilderContext.dynamicPage.properties.containsKey('ScrollBarController')) {
      dynamicUIBuilderContext.dynamicPage.properties['ScrollBarController'] = ScrollController();
    }
    return Scrollbar(
      controller: dynamicUIBuilderContext.dynamicPage.properties['ScrollBarController'],
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
      key: Util.getKey(),
    );
  }
}

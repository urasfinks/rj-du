import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class GestureDetectorWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return GestureDetector(
      key: Util.getKey(),
      onTap: () {
        click(parsedJson, dynamicUIBuilderContext, "onTap");
      },
      onDoubleTap: () {
        click(parsedJson, dynamicUIBuilderContext, "onDoubleTap");
      },
      onHorizontalDragStart: (details) {
        click(parsedJson, dynamicUIBuilderContext, "onHorizontalDragStart");
      },
      onVerticalDragStart: (details) {
        click(parsedJson, dynamicUIBuilderContext, "onVerticalDragStart");
      },
      onVerticalDragUpdate: (details){
        click(parsedJson, dynamicUIBuilderContext, "onVerticalDragUpdate");
      },
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}

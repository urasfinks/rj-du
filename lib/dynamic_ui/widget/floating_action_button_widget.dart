import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class FloatingActionButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SizedBox(
      width: 66,
      height: 66,
      child: FittedBox(
        child: FloatingActionButton(
          key: Util.getKey(),
          onPressed: () {
            click(parsedJson, dynamicUIBuilderContext);
          },
          child: render(parsedJson, "child", null, dynamicUIBuilderContext),
        ),
      ),
    );

  }
}

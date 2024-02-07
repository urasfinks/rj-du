import 'package:rjdu/navigator_app.dart';

import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class FloatingActionButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SizedBox(
      width: 57,
      height: 57,
      child: FittedBox(
        child: FloatingActionButton(
          key: Util.getKey(),
          onPressed: () {
            DynamicUIBuilderContext ctx = dynamicUIBuilderContext;
            if (NavigatorApp.getLast() != null && !parsedJson.containsKey("defContext")) {
              ctx = NavigatorApp.getLast()!.dynamicUIBuilderContext;
            }
            click(parsedJson, ctx);
          },
          child: render(parsedJson, "child", null, dynamicUIBuilderContext),
        ),
      ),
    );
  }
}

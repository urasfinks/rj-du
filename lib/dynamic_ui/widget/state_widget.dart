import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import 'abstract_widget.dart';
import 'package:flutter/material.dart';

class StateWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic>? data = dynamicUIBuilderContext.dynamicPage.stateData
        .get(parsedJson["state"], parsedJson["key"], parsedJson["default"]);
    if (data == null) {
      return Text("StateWidget($parsedJson) is null");
    }
    return render(
      data,
      null,
      const SizedBox(),
      dynamicUIBuilderContext,
    );
  }
}

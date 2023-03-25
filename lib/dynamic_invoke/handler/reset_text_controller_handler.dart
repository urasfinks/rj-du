import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class ResetTextControllerHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['key'])) {
      String key = args["key"];
      TextEditingController tec =
          dynamicUIBuilderContext.dynamicPage.getProperty("${key}_TextEditingController", TextEditingController());
      tec.text = "";
      dynamicUIBuilderContext.dynamicPage.setStateData(key, "");
    } else {
      if (kDebugMode) {
        print("DataSourceSetHandler not contains Keys: [key] in args: $args");
        print(StackTrace.current);
      }
    }
  }
}

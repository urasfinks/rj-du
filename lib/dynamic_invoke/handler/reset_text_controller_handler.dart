import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class ResetTextControllerHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key"])) {
      String key = args["key"];
      TextEditingController tec =
          dynamicUIBuilderContext.dynamicPage.getProperty("${key}_TextEditingController", TextEditingController());
      tec.text = "";
      //Сброс состояния контролера не должен перезагружать страницу
      //Перерисовка при включенном onRebuildClearTemporaryControllerText и setStateInit перезапишет состояние
      //Цель зануления скорее всего, что бы записать новое значение, не держа backspace
      //А так мы просто получим перетерание на старое значение
      dynamicUIBuilderContext.dynamicPage.setStateData(key, "", false);
    } else {
      if (kDebugMode) {
        print("DataSourceSetHandler not contains Keys: [key] in args: $args");
        print(StackTrace.current);
      }
    }
  }
}

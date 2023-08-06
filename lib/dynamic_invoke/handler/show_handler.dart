import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_invoke/handler/data_source_set_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/system_notify_handler.dart';
import 'package:rjdu/dynamic_invoke/handler_custom/custom_loader_open_handler.dart';
import 'package:rjdu/system_notify.dart';

import '../../util.dart';
import '../dynamic_invoke.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class ShowHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["case"])) {
      switch (args["case"]) {
        case "bottomNavigationBar":
          DynamicInvoke().sysInvokeType(
            SystemNotifyHandler,
            {
              "SystemNotifyEnum": SystemNotifyEnum.changeBottomNavigationTab.name,
              "state": "true",
            },
            dynamicUIBuilderContext,
          );
          break;
        case "actionButton":
          DynamicInvoke().sysInvokeType(
            DataSourceSetHandler,
            {
              "uuid": "FloatingActionButton.json",
              "type": "virtual",
              "value": Util.getMutableMap(args["template"]),
            },
            dynamicUIBuilderContext,
          );
          break;
        case "customLoader":
          DynamicInvoke().sysInvokeType(CustomLoaderOpenHandler, args, dynamicUIBuilderContext);
          break;
        default:
          if (kDebugMode) {
            print("HideHandler default case: $args");
          }
          break;
      }
    } else {
      if (kDebugMode) {
        print("HideHandler not contains Keys: [case] in args: $args");
      }
    }
  }
}

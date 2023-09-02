import 'package:rjdu/dynamic_invoke/handler/data_source_set_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/system_notify_handler.dart';
import 'package:rjdu/dynamic_invoke/handler_custom/custom_loader_close_handler.dart';
import 'package:rjdu/system_notify.dart';

import '../../util.dart';
import '../dynamic_invoke.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

class HideHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["case"])) {
      switch (args["case"]) {
        case "snackBar":
          try {
            ScaffoldMessenger.of(dynamicUIBuilderContext.dynamicPage.context!).hideCurrentSnackBar();
          } catch (e, stacktrace) {
            Util.printStackTrace("HideHandler.snackBar args: $args", e, stacktrace);
          }
          break;
        case "keyboard":
          FocusManager.instance.primaryFocus?.unfocus();
          break;
        case "bottomNavigationBar":
          DynamicInvoke().sysInvokeType(
            SystemNotifyHandler,
            {
              "SystemNotifyEnum": SystemNotifyEnum.changeBottomNavigationTab.name,
              "state": "false",
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
              "value": Util.getMutableMap({}),
            },
            dynamicUIBuilderContext,
          );
          break;
        case "customLoader":
          DynamicInvoke().sysInvokeType(CustomLoaderCloseHandler, args, dynamicUIBuilderContext);
          break;
        default:
          Util.p("HideHandler default case: $args");
          break;
      }
    } else {
      Util.p("HideHandler not contains Keys: [case] in args: $args");
    }
  }
}

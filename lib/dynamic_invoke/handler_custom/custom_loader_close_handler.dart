import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_page.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

import '../../navigator_app.dart';

class CustomLoaderCloseHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicPage? dynamicPage = NavigatorApp.getLast(NavigatorApp.selectedTab);
    if (dynamicPage != null) {
      if (dynamicPage.arguments.containsKey("name") &&
          dynamicPage.arguments["name"] == "CustomLoader") {
        int delay = args.containsKey("delay") ? args["delay"] : 0;
        if (delay > 0) {
          Future.delayed(Duration(milliseconds: delay), () {
            pop(dynamicPage.context!);
          });
        } else {
          pop(dynamicPage.context!);
        }
      }
    }
  }

  void pop(BuildContext buildContext) {
    Navigator.pop(buildContext);
  }
}

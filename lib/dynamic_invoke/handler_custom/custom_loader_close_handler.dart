import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_page.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

import '../../navigator_app.dart';

class CustomLoaderCloseHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicPage? dynamicPage = NavigatorApp.getLast(dynamicUIBuilderContext.dynamicPage.openInIndexTab);
    if (dynamicPage != null) {
      if (dynamicPage.arguments.containsKey("name") && dynamicPage.arguments["name"] == "CustomLoader") {
        int delay = args.containsKey("delay") ? args["delay"] : 0;
        if (delay > 0) {
          Future.delayed(Duration(milliseconds: delay), () {
            pop(dynamicPage);
          });
        } else {
          pop(dynamicPage);
        }
      }
    }
  }

  void pop(DynamicPage dynamicPage) {
    if (!NavigatorApp.isLast()) {
      //Если тут не сделать удалние NavigatorApp.removePage при программном закрытии списка
      // Мы будем получть один и тотже последний DynamicPage и получим ошибку, когда dispose страницы отработает
      // А мы заново скажем - закрывайся
      // И в целом, это самое актуальное хранилище, надо что бы данные там обновлялись быстрее чем через dispose
      NavigatorApp.removePage(dynamicPage);
      switch (dynamicPage.dynamicPageOpenType) {
        case DynamicPageOpenType.dialog:
        case DynamicPageOpenType.bottomSheet:
          Navigator.of(dynamicPage.context!, rootNavigator: true).pop();
          break;
        case DynamicPageOpenType.window:
        default:
          Navigator.pop(dynamicPage.context!);
          break;
      }
    }
  }
}

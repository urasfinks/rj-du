import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';

class NavigatorPopHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    int indexTab = args.containsKey('tab') ? args['tab'] : NavigatorApp.selectedTab;
    int count = args.containsKey('count') ? args['count'] : 1;
    if (args.containsKey('toBegin')) {
      count = 9999; //break остановит
    }
    int delay = args.containsKey("delay") ? args["delay"] : 0;
    if (delay > 0) {
      Future.delayed(Duration(milliseconds: delay), () {
        pop(count, indexTab, args);
      });
    } else {
      pop(count, indexTab, args);
    }
  }

  void pop(int count, int indexTab, Map<String, dynamic> args) {
    while (count > 0) {
      if (!NavigatorApp.isLast(indexTab)) {
        NavigatorApp.removePage(NavigatorApp.getLast(indexTab)!);
        Navigator.pop(NavigatorApp.tab[indexTab].context, args);
      } else {
        break;
      }
      count--;
    }
  }
}

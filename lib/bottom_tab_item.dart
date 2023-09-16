import 'package:flutter/material.dart';
import 'dynamic_ui/dynamic_ui.dart';
import 'dynamic_page.dart';
import 'navigator_app.dart';

class BottomTabItem {
  late final BottomNavigationBarItem bottomNavigationBarItem;
  Map<String, dynamic> parsedJson = {};
  late Widget widget;
  late BuildContext context;
  late final DynamicPage dynamicPage;
  late String name;

  BottomTabItem(this.parsedJson) {
    //Если убрать Navigator, то при открытие новой страницы, BottomTabBar уедет с первой страницей
    name = parsedJson["name"];
    dynamicPage = DynamicPage(parsedJson["content"], DynamicPageOpenType.window);
    bottomNavigationBarItem = DynamicUI.render(parsedJson, "tab", null, dynamicPage.dynamicUIBuilderContext);
    NavigatorApp.addNavigatorPage(dynamicPage, NavigatorApp.tab.length);
    widget = Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            context = ctx;
            return dynamicPage;
          },
        );
      },
    );
  }
}

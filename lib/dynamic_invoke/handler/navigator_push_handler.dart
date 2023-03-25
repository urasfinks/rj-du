import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';
import '../../dynamic_page.dart';

class NavigatorPushHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> dataPage = args;
    bool raw = args.containsKey('raw') && args['raw'] == true;
    if (!raw) {
      dataPage.addAll({
        'flutterType': 'Notify',
        'link': args.containsKey("uuid") ? {'template': args['uuid']} : args["link"],
        'linkContainer': 'root',
        'linkDefault': {
          'template': {
            "flutterType": "Scaffold",
            "appBar": {
              "flutterType": "AppBar",
              "title": {"flutterType": "Text", "label": args['label']}
            }
          }
        }
      });
    }

    Navigator.push(
      args.containsKey('tab') ? NavigatorApp.tab[args['tab']].context : NavigatorApp.tab[NavigatorApp.selectedTab].context,
      MaterialPageRoute(
        builder: (context) {
          DynamicPage dynamicPage = DynamicPage(dataPage);
          NavigatorApp.addNavigatorPage(dynamicPage);
          return dynamicPage;
        },
      ),
    );
  }
}

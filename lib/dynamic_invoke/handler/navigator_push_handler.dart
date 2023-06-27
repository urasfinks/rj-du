import 'package:rjdu/dynamic_ui/type_parser.dart';

import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';
import '../../dynamic_page.dart';

class NavigatorPushHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> dataPage = args;

    String type = args.containsKey("type") ? args["type"] : "Window";
    if (!["Window", "BottomSheet", "Dialog"].contains(type)) {
      type = "Window";
    }

    bool raw = args.containsKey('raw') && args['raw'] == true;
    BuildContext buildContext = args.containsKey('tab')
        ? NavigatorApp.tab[args['tab']].context
        : NavigatorApp.tab[NavigatorApp.selectedTab].context;

    switch (type) {
      case "BottomSheet":
        bottomSheet(buildContext, raw, dataPage);
        break;
      case "Dialog":
        dialog(buildContext, raw, dataPage);
        break;
      default:
        window(buildContext, raw, dataPage);
        break;
    }
  }

  void dialog(
      BuildContext buildContext, bool raw, Map<String, dynamic> dataPage) {
    if (!raw) {
      dataPage.addAll(
        {
          'name': dataPage.containsKey('name') ? dataPage['name'] : '',
          'flutterType': 'Notify',
          'link': dataPage.containsKey('uuid')
              ? {'template': dataPage['uuid']}
              : dataPage['link'],
          'linkContainer': 'root',
          'linkDefault': dataPage.containsKey('linkDefault')
              ? dataPage['linkDefault']
              : {
                  'template': {'flutterType': 'Text', 'label': ''}
                }
        },
      );
    }
    showGeneralDialog(
      context: buildContext,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        DynamicPage dynamicPage = DynamicPage(dataPage);
        NavigatorApp.addNavigatorPage(dynamicPage);
        return dynamicPage;
      },
    );
  }

  void bottomSheet(
      BuildContext buildContext, bool raw, Map<String, dynamic> dataPage) {
    if (!raw) {
      dataPage.addAll(
        {
          'name': dataPage.containsKey('name') ? dataPage['name'] : '',
          'flutterType': 'Notify',
          'link': dataPage.containsKey('uuid')
              ? {'template': dataPage['uuid']}
              : dataPage['link'],
          'linkContainer': 'root',
          'linkDefault': dataPage.containsKey('linkDefault')
              ? dataPage['linkDefault']
              : {
                  'template': {'flutterType': 'Text', 'label': ''}
                }
        },
      );
    }
    DynamicPage dynamicPage = DynamicPage(dataPage);
    NavigatorApp.addNavigatorPage(dynamicPage);
    //showModalBottomSheet вызывает builder при скроле
    //Постоянное пересоздание страницы создаёт мерцание
    //Подкешируем для избежания лагов UI

    showModalBottomSheet(
      context: buildContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TypeParser.parseDouble(dataPage["borderRadius"]) ?? 15.0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        return dynamicPage;
      },
    );
  }

  void window(
      BuildContext buildContext, bool raw, Map<String, dynamic> dataPage) {
    if (!raw) {
      dataPage.addAll(
        {
          'name': dataPage.containsKey('name') ? dataPage['name'] : '',
          'flutterType': 'Notify',
          'link': dataPage.containsKey('uuid')
              ? {'template': dataPage['uuid']}
              : dataPage['link'],
          'linkContainer': 'root',
          'linkDefault': dataPage.containsKey('linkDefault')
              ? dataPage['linkDefault']
              : {
                  'template': {
                    'flutterType': 'Scaffold',
                    'appBar': {
                      'flutterType': 'AppBar',
                      'title': {
                        'flutterType': 'Text',
                        'label': dataPage['label']
                      }
                    }
                  }
                }
        },
      );
    }

    Navigator.push(
      buildContext,
      MaterialPageRoute(
        fullscreenDialog: dataPage['fullscreenDialog'] ?? false,
        builder: (context) {
          DynamicPage dynamicPage = DynamicPage(dataPage);
          NavigatorApp.addNavigatorPage(dynamicPage);
          return dynamicPage;
        },
      ),
    );
  }
}

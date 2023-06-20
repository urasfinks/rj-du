library rjdu;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rjdu/db/data_migration.dart';
import 'package:rjdu/dynamic_page.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/iterator_theme/iterator_theme_loader.dart';
import 'package:rjdu/dynamic_ui/widget/template_widget.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/translate.dart';
import 'package:rjdu/web_socket_service.dart';
import 'package:uuid/uuid.dart';
import 'bottom_tab_item.dart';
import 'data_sync.dart';
import 'db/data_source.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'navigator_app.dart';
import 'storage.dart';
import 'http_client.dart';

class RjDu {
  static void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    DynamicInvoke().init();
    await Storage().init();
    GlobalSettings().init();

    Storage().set('uuid', const Uuid().v4(), false);
    Storage().set('version', GlobalSettings().version, false);
    Storage().set('isAuth', "false", false);

    DataSource().init();

    HttpClient.init();
    Translate().init();
    DataSync().init();
    WebSocketService().init();

    SystemNotify().listen(SystemNotifyEnum.changeTabOrHistoryPop, (state) {
      NavigatorApp.getLast()?.renderFloatingActionButton();
    });
  }

  static Future<DynamicPage> runApp() async {
    List<String> loadTabData = await DataMigration.loadTabData();
    for (String tabData in loadTabData) {
      NavigatorApp.tab.add(
        BottomTabItem(json.decode(tabData)),
      );
    }

    IteratorThemeLoader.load(
        await DataMigration.loadIAsset("systemData", "IteratorTheme"));
    TemplateWidget.load(
        await DataMigration.loadIAsset("template", "TemplateWidget"));

    return DynamicPage(const {
      'flutterType': 'Notify',
      'link': {'template': 'main.json'},
      'linkContainer': 'root',
      'linkDefault': {
        'template': {'flutterType': 'MaterialApp'}
      }
    });
  }
}

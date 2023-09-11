library rjdu;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rjdu/audio_component.dart';
import 'package:rjdu/db/data_migration.dart';
import 'package:rjdu/dynamic_page.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/iterator_theme/iterator_theme_loader.dart';
import 'package:rjdu/dynamic_ui/widget/template_widget.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/translate.dart';
import 'package:rjdu/util.dart';
import 'package:rjdu/web_socket_service.dart';
import 'bottom_tab_item.dart';
import 'data_sync.dart';
import 'db/data_source.dart';
import 'deep_link.dart';
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
    AudioComponent().init();

    Storage().set("uuid", Util.uuid(), false);
    Util.p("I'am: ${Storage().get("uuid", "")}");
    Storage().set("unique", Util.uuid(), false);
    Storage().set("version", GlobalSettings().version, false);
    Storage().set("isAuth", "false", false);
    Storage().set("mail", "", false);
    Storage().set("lastMail", "", false);
    Storage().set("lastSync", "", false);

    DataSource().init();

    if (GlobalSettings().debugSql.isNotEmpty) {
      // Для отладки запросов нет необходимости в загрузке всего приложения
      // Загрузка приложения может только мешать выборке изменяя данные в ходе работы
      // Поэтому если смотрим что в локальной БД - дальнейшая работа приложения невозможна
      return;
    }

    HttpClient.init();
    Translate().init();
    DataSync().init();
    WebSocketService().init();
    DeepLink.init();

    SystemNotify().subscribe(SystemNotifyEnum.changeViewport, (state) {
      AudioComponent().stop(); //Лучше stop чем pause а то вдруг на другой странице тоже проигрыватель будет
      NavigatorApp.getLast()?.onActive();
    });
    SystemNotify().subscribe(SystemNotifyEnum.openDynamicPage, (state) {
      AudioComponent().stop();
    });

    SystemNotify().subscribe(SystemNotifyEnum.appLifecycleState, (state) {
      if (state == AppLifecycleState.resumed.name) {
        AudioComponent().init();
      }
    });

    SystemNotify().subscribe(SystemNotifyEnum.changeThemeData, (state) {
      NavigatorApp.reloadAllPages();
    });

    if (Storage().isUpdateApplicationVersion()) {
      Storage().set("version", GlobalSettings().version);
    }
  }

  static Future<DynamicPage> runApp() async {
    if (GlobalSettings().debugSql.isNotEmpty) {
      return DynamicPage(const {"flutterType": "SizeBox"});
    }
    List<String> loadTabData = await DataMigration.loadTabData();
    for (String tabData in loadTabData) {
      NavigatorApp.tab.add(
        BottomTabItem(json.decode(tabData)),
      );
    }
    //Сначала packages/rjdu/lib/, что бы можно было перекрыть проектными файлами
    IteratorThemeLoader.load(
        await DataMigration.loadAssetByMask("systemData/iteratorTheme", "", "packages/rjdu/lib/"), "rjdu");
    TemplateWidget.load(await DataMigration.loadAssetByMask("template/widget", "", "packages/rjdu/lib/"), "rjdu");

    IteratorThemeLoader.load(
        await DataMigration.loadAssetByMask("systemData/iteratorTheme", "IteratorTheme"), "project");
    TemplateWidget.load(await DataMigration.loadAssetByMask("template/widget", ""), "project");

    return DynamicPage(const {
      "flutterType": "Notify",
      "link": {},
      "context": {
        "key": "runApp",
        "data": {
          "template": {"flutterType": "MaterialApp"}
        }
      }
    });
  }
}

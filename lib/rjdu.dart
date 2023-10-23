library rjdu;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rjdu/audio_component.dart';
import 'package:rjdu/db/data_migration.dart';
import 'package:rjdu/dynamic_page.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/iterator_theme/iterator_theme_loader.dart';
import 'package:rjdu/dynamic_ui/widget/template_widget.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/theme_provider.dart';
import 'package:rjdu/translate.dart';
import 'package:rjdu/util.dart';
import 'package:rjdu/web_socket_service.dart';
import 'bottom_tab_item.dart';
import 'data_sync.dart';
import 'db/data_source.dart';
import 'deep_link.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'dynamic_invoke/handler/hide_handler.dart';
import 'navigator_app.dart';
import 'storage.dart';
import 'http_client.dart';

class RjDu {
  static init() async {
    Util.p("RjDu.init()");
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
    Storage().set("accountName", "", false);

    //Надо ждать загрузку из assets шаблонов
    await DataSource().init();

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
      if (NavigatorApp.getLast() != null) {
        NavigatorApp.getLast()?.onActive();
        // Проблема в таком подходе для лоадера, когда мы его закрываем - то получаем изменение viewport
        // И оно его скрывает, а там важная информация после загрузки данных с сервера
        // Проблема воспроизодилась на Account.json когда просто не открывался snackBar
        // Принято решение скрывать только при переключенях табов
        if (state == "onChangeTab") {
          DynamicInvoke()
              .sysInvokeType(HideHandler, {"case": "snackBar"}, NavigatorApp.getLast()!.dynamicUIBuilderContext);
        }
      }
    });
    SystemNotify().subscribe(SystemNotifyEnum.openDynamicPage, (state) {
      AudioComponent().stop();
    });

    SystemNotify().subscribe(SystemNotifyEnum.appLifecycleState, (state) {
      if (state == AppLifecycleState.resumed.name) {
        AudioComponent().init();
      }
    });
    androidUpdateSubAppBar();

    SystemNotify().subscribe(SystemNotifyEnum.changeThemeData, (state) {
      androidUpdateSubAppBar();
      NavigatorApp.reloadAllPages();
    });

    if (Storage().isUpdateApplicationVersion()) {
      Storage().set("version", GlobalSettings().version);
    }
  }

  static androidUpdateSubAppBar() {
    if (Util.isAndroid()) {
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      ThemeData curTheme =
          brightness == Brightness.dark ? ThemeProvider.darkThemeData() : ThemeProvider.lightThemeData();
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            HexColor.fromRGB(curTheme.bottomNavigationBarTheme.backgroundColor!.getChannel()).darkness(3),
        systemNavigationBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ));
    }
  }

  static runApp() async {
    await RjDu.init();
    Util.p("RjDu.runApp()");
    if (GlobalSettings().debugSql.isNotEmpty) {
      return DynamicPage(const {"flutterType": "SizeBox"}, DynamicPageOpenType.window);
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
    }, DynamicPageOpenType.window);
  }
}

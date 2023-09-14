import 'package:rjdu/dynamic_ui/type_parser.dart';

import '../../navigator_app.dart';
import '../../system_notify.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';
import '../../dynamic_page.dart';

class NavigatorPushHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String type = args.containsKey("type") ? args["type"] : "Window";
    if (!["Window", "BottomSheet", "Dialog"].contains(type)) {
      type = "Window";
    }

    bool raw = args.containsKey("raw") && args["raw"] == true;
    BuildContext buildContext = args.containsKey("tab")
        ? NavigatorApp.tab[args["tab"]].context
        : NavigatorApp.tab[NavigatorApp.selectedTab].context;

    switch (type) {
      case "BottomSheet":
        bottomSheet(buildContext, raw, args);
        break;
      case "Dialog":
        dialog(buildContext, raw, args);
        break;
      default:
        window(buildContext, raw, args);
        break;
    }
    SystemNotify().emit(SystemNotifyEnum.openDynamicPage, type);
  }

  void dialog(BuildContext buildContext, bool raw, Map<String, dynamic> args) {
    if (!raw) {
      args.addAll(
        {
          "name": args.containsKey("name") ? args["name"] : "",
          "flutterType": "Notify",
          "link": args.containsKey("uuid") ? {"template": args["uuid"]} : args["link"],
          "context": args.containsKey("context")
              ? args["context"]
              : {
                  "key": "NavigatorPushHandlerDialog",
                  "data": {
                    "template": {"flutterType": "Text", "label": ""}
                  }
                }
        },
      );
    }
    showGeneralDialog(
      useRootNavigator: TypeParser.parseBool(args["useRootNavigator"]) ?? true,
      context: buildContext,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        DynamicPage dynamicPage = DynamicPage(args);
        NavigatorApp.addNavigatorPage(dynamicPage);
        return dynamicPage;
      },
    );
  }

  void bottomSheet(BuildContext buildContext, bool raw, Map<String, dynamic> args) {
    if (!raw) {
      args.addAll(
        {
          "name": args.containsKey("name") ? args["name"] : "",
          "flutterType": "Notify",
          "link": args.containsKey("uuid") ? {"template": args["uuid"]} : args["link"],
          "context": args.containsKey("context")
              ? args["context"]
              : {
                  "key": "NavigatorPushHandlerBottomSheet",
                  "data": {
                    "template": {"flutterType": "Text", "label": ""}
                  }
                }
        },
      );
    }
    DynamicPage dynamicPage = DynamicPage(args);
    NavigatorApp.addNavigatorPage(dynamicPage);
    //showModalBottomSheet вызывает builder при скроле
    //Постоянное пересоздание страницы создаёт мерцание
    //Подкешируем для избежания лагов UI

    showModalBottomSheet(
      // Закрытие tap по пустому месту
      isDismissible: TypeParser.parseBool(args["isDismissible"]) ?? true,
      // Тащить пальцем для закрытия
      enableDrag: TypeParser.parseBool(args["enableDrag"]) ?? true,
      useSafeArea: TypeParser.parseBool(args["useSafeArea"]) ?? true,
      //Если false - содержимое bottomSheet будет под bottomTabBar
      useRootNavigator: TypeParser.parseBool(args["useRootNavigator"]) ?? true,
      isScrollControlled: TypeParser.parseBool(args["isScrollControlled"]) ?? true,
      context: buildContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TypeParser.parseDouble(args["borderRadius"]) ?? 15.0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        if (args.containsKey("height")) {
          return SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom + (TypeParser.parseDouble(args["height"]) ?? 300.0),
            //Scafold нужен для Snackbar иначе Alert мы никогда не увидим
            child: Scaffold(
              backgroundColor: TypeParser.parseColor(args["backgroundColor"] ?? "schema:primaryContainer", context),
              body: dynamicPage,
            ),
          );
        } else {
          //Scafold нужен для Snackbar иначе Alert мы никогда не увидим
          return Scaffold(
            backgroundColor: TypeParser.parseColor(args["backgroundColor"] ?? "schema:primaryContainer", context),
            body: dynamicPage,
          );
        }
      },
    );
  }

  void window(BuildContext buildContext, bool raw, Map<String, dynamic> dataPage) {
    if (!raw) {
      dataPage.addAll(
        {
          "name": dataPage.containsKey("name") ? dataPage["name"] : "",
          "flutterType": "Notify",
          "link": dataPage.containsKey("uuid") ? {"template": dataPage["uuid"]} : dataPage["link"],
          "context": dataPage.containsKey("context")
              ? dataPage["context"]
              : {
                  "key": "NavigatorPushHandlerWindow",
                  "data": {
                    "template": {
                      "flutterType": "Scaffold",
                      "appBar": {
                        "flutterType": "AppBar",
                        "title": {"flutterType": "Text", "label": dataPage["label"]}
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
        fullscreenDialog: dataPage["fullscreenDialog"] ?? false,
        builder: (context) {
          DynamicPage dynamicPage = DynamicPage(dataPage);
          NavigatorApp.addNavigatorPage(dynamicPage);
          return dynamicPage;
        },
      ),
    );
  }
}

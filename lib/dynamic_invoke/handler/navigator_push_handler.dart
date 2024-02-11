import 'dart:ui';

import 'package:rjdu/dynamic_ui/type_parser.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../navigator_app.dart';
import '../../system_notify.dart';
import '../../theme_provider.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/material.dart';
import '../../dynamic_page.dart';

class NavigatorPushHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicPageOpenType dynamicPageOpenType =
        TypeParser.parseDynamicPageOpenType(args["type"]) ?? DynamicPageOpenType.window;

    bool raw = args.containsKey("raw") && args["raw"] == true;
    BuildContext buildContext = args.containsKey("tab")
        ? NavigatorApp.tab[args["tab"]].context
        : NavigatorApp.tab[NavigatorApp.selectedTab].context;

    switch (dynamicPageOpenType) {
      case DynamicPageOpenType.bottomSheet:
        bottomSheet(buildContext, raw, args, dynamicUIBuilderContext);
        break;
      case DynamicPageOpenType.dialog:
        dialog(buildContext, raw, args, dynamicUIBuilderContext);
        break;
      default:
        window(buildContext, raw, args, dynamicUIBuilderContext);
        break;
    }
    SystemNotify().emit(SystemNotifyEnum.openDynamicPage, dynamicPageOpenType.name);
  }

  void dialog(
      BuildContext buildContext, bool raw, Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
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
    bool blur = args.containsKey("blur") && args["blur"] == true;
    double blurValue = ThemeProvider.blur;
    if (args.containsKey("blurValue")) {
      double? tmp = TypeParser.parseDouble(args["blurValue"]);
      if (tmp != null) {
        blurValue = tmp;
      }
    }

    double barrierColorOpacity = 0.8;
    if (args.containsKey("barrierColorOpacity")) {
      double? tmp = TypeParser.parseDouble(args["barrierColorOpacity"]);
      if (tmp != null) {
        barrierColorOpacity = tmp;
      }
    }

    showGeneralDialog(
      //Если false - содержимое dialog будет под bottomTabBar
      //Менять нельзя, потому что Navigator.pop настроен на удаление данного типа открытия через корневой контекст
      useRootNavigator: true,
      context: buildContext,

      // blur background
      barrierDismissible: blur ? true : false,
      barrierLabel: blur ? '' : null,
      barrierColor: ThemeProvider.getThemeColor().withOpacity(barrierColorOpacity),
      transitionBuilder: blur
          ? (ctx, anim1, anim2, child) => BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: blurValue * anim1.value, sigmaY: blurValue * anim1.value),
                child: FadeTransition(
                  opacity: anim1,
                  child: child,
                ),
              )
          : null,

      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        DynamicPage dynamicPage = DynamicPage(args, DynamicPageOpenType.dialog);
        NavigatorApp.addNavigatorPage(dynamicPage);
        return dynamicPage;
      },
    ).then((value) => onPop(value, dynamicUIBuilderContext));
  }

  void bottomSheet(
      BuildContext buildContext, bool raw, Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
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
    DynamicPage dynamicPage = DynamicPage(args, DynamicPageOpenType.bottomSheet);
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
      //Менять нельзя, потому что Navigator.pop настроен на удаление данного типа открытия через корневой контекст
      useRootNavigator: true,
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
    ).then((value) => onPop(value, dynamicUIBuilderContext));
  }

  void window(BuildContext buildContext, bool raw, Map<String, dynamic> dataPage,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
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
          DynamicPage dynamicPage = DynamicPage(dataPage, DynamicPageOpenType.window);
          NavigatorApp.addNavigatorPage(dynamicPage);
          return dynamicPage;
        },
      ),
    ).then((value) => onPop(value, dynamicUIBuilderContext));
  }

  void onPop(dynamic callbackArgs, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Util.p("NavigatorPushHandler.onPop($callbackArgs)");
    if (callbackArgs.runtimeType.toString().contains("Map<")) {
      Map<String, dynamic> args = Util.convertMap(callbackArgs as Map);
      if (args.isNotEmpty && args.containsKey("onPop")) {
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onPop");
      }
    }
  }
}

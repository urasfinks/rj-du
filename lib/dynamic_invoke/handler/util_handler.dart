import 'package:rjdu/data_sync.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/navigator_app.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import '../../util/template/directive.dart';
import '../../web_socket_service.dart';
import '../dynamic_invoke.dart';
import 'abstract_handler.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_share/flutter_share.dart';
import 'package:wakelock/wakelock.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'alert_handler.dart';

class UtilHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "dynamicPageApi":
        dynamicUIBuilderContext.dynamicPage.api(args);
        break;
      case "reloadAllPage":
        NavigatorApp.reloadAllPages();
        break;
      case "webSocketConnect":
        WebSocketService().addListener(dynamicUIBuilderContext.dynamicPage);
        break;
      case "webSocketDisconnect":
        WebSocketService().removeListener(dynamicUIBuilderContext.dynamicPage);
        break;
      case "directive":
        return {
          args["case"]: TemplateDirective.invoke(
            args["directive"] ?? "default",
            args["data"],
            args["arguments"] ?? [],
            dynamicUIBuilderContext,
          )
        };
      case "platform":
        return {args["case"]: Util.getPlatformName()};
      case "uuid":
        return {args["case"]: Util.uuid()};
      case "md5":
        return {args["case"]: md5.convert(utf8.encode(args["data"])).toString()};
      case "template":
        Map<String, dynamic> result = {};
        if (args.containsKey("map")) {
          for (MapEntry<String, dynamic> item in args["map"].entries) {
            result[item.key] = Util.template(item.value, dynamicUIBuilderContext);
          }
        } else if (args.containsKey("data")) {
          result["data"] = Util.template(args["data"], dynamicUIBuilderContext);
        }
        return result;
      case "share":
        FlutterShare.share(title: args["title"] ?? "Поделиться", text: args["data"]);
        break;
      case "dataSync":
        if (args["onSync"] != null) {
          Future<void> sync2 = DataSync().sync();
          sync2.then((_) {
            AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onSync");
          }).onError((error, stackTrace) {
            Util.printStackTrace("DataSyncHandler.handler()", error, stackTrace);
          });
        } else {
          DataSync().sync();
        }
        break;
      case "wakeLock":
        Wakelock.enable();
        break;
      case "wakeUnlock":
        Wakelock.disable();
        break;
      case "urlLauncher":
        launch(args["url"], forceSafariVC: false);
        break;
      case "copyClipboard":
        Clipboard.setData(ClipboardData(text: args["data"]));
        DynamicInvoke().sysInvokeType(AlertHandler, {"label": "Скопировано в буфер обмена"}, dynamicUIBuilderContext);
        break;
      case "dynamicInvoke":
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "invokeArgs");
        break;
      default:
        Util.p("SystemHandler.handle() default case args: $args");
        break;
    }
  }
}

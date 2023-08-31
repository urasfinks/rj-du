import 'package:flutter/foundation.dart';
import 'package:rjdu/navigator_app.dart';
import 'package:uni_links/uni_links.dart';

import 'dynamic_invoke/dynamic_invoke.dart';
import 'global_settings.dart';

class DeepLink {
  static void init() {
    handleInitialUri();
    handleIncomingLinks();
  }

  static void open(Uri uri) {
    List<String> listArg = [];
    listArg.addAll(uri.pathSegments);
    //[deeplink, v1, ConnectCodeNames, code, 392496]
    Map<String, dynamic> args = {};
    args["deeplink"] = listArg.removeAt(0);
    args["version"] = listArg.removeAt(0);
    args["switch"] = listArg.removeAt(0);
    try {
      for (int i = 0; i < listArg.length; i += 2) {
        String key = listArg[i];
        String value = listArg[i + 1];
        args[key] = value;
      }
    } catch (e, stacktrace) {
      debugPrintStack(
        stackTrace: stacktrace,
        maxFrames: GlobalSettings().debugStackTraceMaxFrames,
        label: "DeepLink.open() Exception: $e",
      );
      args["error"] = e.toString();
    }
    if (kDebugMode) {
      print("DeepLink $uri; args: ${args}");
    }
    DynamicInvoke().jsInvoke("DeepLink.js", args, NavigatorApp.getLast()!.dynamicUIBuilderContext);
  }

  static Future<void> handleInitialUri() async {
    final uri = await getInitialUri();
    if (uri != null) {
      open(uri);
    }
  }

  static void handleIncomingLinks() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        open(uri);
      }
    }, onError: (e, stacktrace) {
      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stacktrace,
          maxFrames: GlobalSettings().debugStackTraceMaxFrames,
          label: "DeepLink.uriLinkStream.listen() Exception: $e",
        );
      }
    });
  }
}

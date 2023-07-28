import 'package:flutter/foundation.dart';
import 'package:rjdu/navigator_app.dart';
import 'package:uni_links/uni_links.dart';

import 'dynamic_invoke/dynamic_invoke.dart';

class DeepLink {
  static void init() {
    handleInitialUri();
    handleIncomingLinks();
  }

  static void open(Uri uri) {
    List<String> listArg = [];
    listArg.addAll(uri.pathSegments);
    listArg.removeAt(0);
    Map<String, dynamic> args = {};
    args["version"] = listArg[0];
    args["switch"] = listArg[1];
    for (int i = 2; i < listArg.length; i += 2) {
      String key = listArg[i];
      String value = listArg[i + 1];
      args[key] = value;
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
    }, onError: (Object err) {
      if (kDebugMode) {
        print(err);
      }
    });
  }
}

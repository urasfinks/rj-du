import 'package:rjdu/navigator_app.dart';
import 'package:rjdu/util.dart';
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
    //[deeplink, v1, ConnectAlternativeWord, code, 392496]
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
      Util.printStackTrace("DeepLink.open()", e, stacktrace);
      args["error"] = e.toString();
    }
    Util.p("DeepLink $uri; args: $args");
    if (NavigatorApp.getLast() != null) {
      DynamicInvoke().jsInvoke("DeepLink.js", args, NavigatorApp.getLast()!.dynamicUIBuilderContext);
    }
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
      Util.printStackTrace("DeepLink.uriLinkStream.listen()", e, stacktrace);
    });
  }
}

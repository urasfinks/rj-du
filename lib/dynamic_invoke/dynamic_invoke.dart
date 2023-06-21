import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import '../db/data_source.dart';
import '../dynamic_page.dart';
import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../navigator_app.dart';
import 'package:flutter_js/flutter_js.dart';

import '../data_type.dart';
import '../util.dart';
import 'handler/alert_handler.dart';
import 'handler/copy_clipboard_handler.dart';
import 'handler/data_source_set_handler.dart';
import 'handler/db_query_handler.dart';
import 'handler/get_state_data_handler.dart';
import 'handler/get_storage_handler.dart';
import 'handler/hide_keyboard_handler.dart';
import 'handler/http_handler.dart';
import 'handler/navigator_push_handler.dart';
import 'handler/page_reload_handler.dart';
import 'handler/reset_text_controller_handler.dart';
import 'handler/set_state_data_handler.dart';
import 'handler/md5_handler.dart';
import 'handler/navigator_pop_handler.dart';
import 'handler/select_tab_handler.dart';
import 'handler/set_storage_handler.dart';
import 'handler/share_handler.dart';
import 'handler/template_handler.dart';
import 'handler/test_handler.dart';
import 'handler/url_launcher_handler.dart';
import 'handler/uuid_handler.dart';
import 'handler_custom/custom_loader_close_handler.dart';
import 'handler_custom/custom_loader_open_handler.dart';

class DynamicInvoke {
  static final DynamicInvoke _singleton = DynamicInvoke._internal();

  factory DynamicInvoke() {
    return _singleton;
  }

  DynamicInvoke._internal();

  JavascriptRuntime? javascriptRuntime;

  Map<String, Function> handler = {
    'NavigatorPush': NavigatorPushHandler().handle,
    'NavigatorPop': NavigatorPopHandler().handle,
    'DataSourceSet': DataSourceSetHandler().handle,
    'Template': TemplateHandler().handle,
    'Alert': AlertHandler().handle,
    'UrlLauncher': UrlLauncherHandler().handle,
    'CopyClipboardHandler': CopyClipboardHandler().handle,
    'MD5': MD5Handler().handle,
    'Share': ShareHandler().handle,
    'SelectTab': SelectTabHandler().handle,
    'SetStateData': SetStateDataHandler().handle,
    'GetStateData': GetStateDataHandler().handle,
    'Test': TestHandler().handle,
    'Uuid': UuidHandler().handle,
    'DbQuery': DbQueryHandler().handle,
    'HideKeyboard': HideKeyboardHandler().handle,
    'ResetTextController': ResetTextControllerHandler().handle,
    'PageReload': PageReloadHandler().handle,
    'Http': HttpHandler().handle,
    'CustomLoaderOpen': CustomLoaderOpenHandler().handle,
    'CustomLoaderClose': CustomLoaderCloseHandler().handle,
    'SetStorage': SetStorageHandler().handle,
    'GetStorage': GetStorageHandler().handle,
  };

  init() {
    if (kDebugMode) {
      print("DynamicInvoke.init()");
    }
    javascriptRuntime = getJavascriptRuntime();
    javascriptRuntime?.init();
    for (MapEntry<String, Function> item in handler.entries) {
      javascriptRuntime!.onMessage(item.key, (dynamic args) {
        //print("DynamicInvoke.onMessage() args: $args");
        String pageUuid = args["_rjduPageUuid"];
        args.removeWhere((key, value) => key == "_rjduPageUuid");
        DynamicPage? pageByUuid = NavigatorApp.getPageByUuid(pageUuid);
        dynamic result;
        if (pageByUuid != null) {
          result = sysInvoke(
              item.key, args, pageByUuid.dynamicUIBuilderContext, true);
        }
        if (result == null) {
          return null;
        }
        return result is String ? result : json.encode(result);
      });
    }
    DataSource().subscribe("global.js", (uuid, data) {
      if (data != null && data.containsKey("js")) {
        javascriptRuntime?.evaluate(data["js"]);
      }
    });
  }

  DynamicUIBuilderContext changeContext(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.containsKey("changeContext") &&
        args["changeContext"] == "lastPage") {
      dynamicUIBuilderContext = NavigatorApp.getLast()!.dynamicUIBuilderContext;
    }
    return dynamicUIBuilderContext;
  }



  dynamic sysInvoke(String handler, Map<String, dynamic> inArgs,
      DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool jsContext = false]) {
    if (this.handler.containsKey(handler)) {
      dynamicUIBuilderContext = changeContext(inArgs, dynamicUIBuilderContext);
      Map<String, dynamic> args = Util.templateArguments(
          Util.getMutableMap(inArgs), dynamicUIBuilderContext);
      String log = "";
      if (kDebugMode) {
        log = "DynamicInvoke.sysInvoke($handler, $inArgs)\ntemplate:\n";
        log += "${Util.jsonPretty(args)}\n";
        if (jsContext) {
          log += "from JsInvoke\n";
        }
      }
      dynamic result = Function.apply(
          this.handler[handler]!, [args, dynamicUIBuilderContext]);
      if (kDebugMode) {
        if (args.containsKey("printResult")) {
          Util.log("$log => $result");
        }
      }
      if (result != null) {
        return result;
      }
    } else {
      if (kDebugMode) {
        print("DynamicInvoke.call() handler[$handler] undefined");
      }
    }
    return null;
  }

  void jsInvoke(
    String uuid,
    Map<String, dynamic> args,
    DynamicUIBuilderContext dynamicUIBuilderContext, [
    bool includeContext = false,
    bool includeContainer = false,
    bool includeStateData = false,
    bool includePageArgument = false,
  ]) {
    args = Util.templateArguments(args, dynamicUIBuilderContext);

    if (args.containsKey("includeAll") && args["includeAll"] == true) {
      includeStateData = true;
      includeContainer = true;
      includeContext = true;
      includePageArgument = true;
    } else {
      if (args.containsKey("includeStateData") &&
          args["includeStateData"] == true) {
        includeStateData = true;
      }
      if (args.containsKey("includeContainer") &&
          args["includeContainer"] == true) {
        includeContainer = true;
      }
      if (args.containsKey("includeContext") &&
          args["includeContext"] == true) {
        includeContext = true;
      }
      if (args.containsKey("includePageArgument") &&
          args["includePageArgument"] == true) {
        includePageArgument = true;
      }
    }

    dynamicUIBuilderContext = changeContext(args, dynamicUIBuilderContext);
    DataSource().get(uuid, (uuid, data) {
      if (data != null && data.containsKey(DataType.js.name)) {
        String? result = _eval(
          dynamicUIBuilderContext.dynamicPage.uuid,
          data[DataType.js.name],
          json.encode(args),
          includeContext ? json.encode(dynamicUIBuilderContext.data) : '',
          includeContainer
              ? json.encode(
                  dynamicUIBuilderContext.dynamicPage.getContainerData())
              : '',
          includeStateData
              ? json.encode(dynamicUIBuilderContext.dynamicPage.stateData.value)
              : '',
          includePageArgument
              ? json.encode(dynamicUIBuilderContext.dynamicPage.arguments)
              : '',
        );
        if (result != null) {
          if (kDebugMode) {
            //print("DynamicInvoke.eval() => $result");
          }
        }
      } else {
        if (kDebugMode) {
          print("DynamicJS.eval() DataSource.get($uuid) undefined");
        }
      }
    });
  }

  String? _eval(String pageUuid, String js, String args, String context,
      String container, String state, String pageArgs) {
    if (args.isNotEmpty) {
      args = "bridge.args = $args;";
    }
    if (context.isNotEmpty) {
      context = "bridge.context = $context;";
    }
    if (container.isNotEmpty) {
      container = "bridge.container = $container;";
    }
    if (state.isNotEmpty) {
      state = "bridge.state = $state;";
    }
    if (pageArgs.isNotEmpty) {
      pageArgs = "bridge.pageArgs = $pageArgs;";
    }
    pageUuid = "bridge.pageUuid = '$pageUuid';";
    String jsCode =
        "bridge.clearAll();\n$pageUuid\n$args\n$context\n$container\n$state\n$pageArgs\n$js";
    //print("\n\nJS CODE BLOCK======================\n$jsCode\n===================FINISH BLOCK\n\n");
    return javascriptRuntime!.evaluate(jsCode).stringResult;
  }
}

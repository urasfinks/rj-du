import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:rjdu/assets_data.dart';
import 'package:rjdu/dynamic_invoke/handler/audio_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/log_handler.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/storage.dart';
import 'package:rjdu/util/template.dart';
import '../db/data_source.dart';
import '../dynamic_page.dart';
import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../navigator_app.dart';
import 'package:flutter_js/flutter_js.dart';

import '../data_type.dart';
import '../util.dart';
import 'handler/show_handler.dart';
import 'handler/alert_handler.dart';
import 'handler/data_source_set_handler.dart';
import 'handler/db_query_handler.dart';
import 'handler/get_state_data_handler.dart';
import 'handler/get_storage_handler.dart';
import 'handler/hide_handler.dart';
import 'handler/http_handler.dart';
import 'handler/navigator_push_handler.dart';
import 'handler/page_reload_handler.dart';
import 'handler/controller_handler.dart';
import 'handler/set_state_data_handler.dart';
import 'handler/navigator_pop_handler.dart';
import 'handler/select_tab_handler.dart';
import 'handler/set_storage_handler.dart';
import 'handler/subscribe_reload.dart';
import 'handler/util_handler.dart';
import 'handler/system_notify_handler.dart';
import 'handler_custom/custom_loader_close_handler.dart';
import 'handler_custom/custom_loader_open_handler.dart';

class DynamicInvoke {
  static final DynamicInvoke _singleton = DynamicInvoke._internal();

  factory DynamicInvoke() {
    return _singleton;
  }

  DynamicInvoke._internal();

  JavascriptRuntime? javascriptRuntime;

  Map<String, Function> handler = {};

  init() {
    Util.p("DynamicInvoke.init()");

    NavigatorPushHandler();
    NavigatorPopHandler();
    DataSourceSetHandler();
    AlertHandler();
    SelectTabHandler();
    SetStateDataHandler();
    GetStateDataHandler();
    DbQueryHandler();
    ControllerHandler();
    PageReloadHandler();
    HttpHandler();
    CustomLoaderOpenHandler();
    CustomLoaderCloseHandler();
    SetStorageHandler();
    GetStorageHandler();
    ShowHandler();
    HideHandler();
    SystemNotifyHandler();
    SubscribeReloadHandler();
    UtilHandler();
    AudioHandler();
    LogHandler();

    javascriptRuntime = getJavascriptRuntime();
    javascriptRuntime?.init();
    for (MapEntry<String, Function> item in handler.entries) {
      javascriptRuntime!.onMessage(item.key, (dynamic args) {
        try {
          String pageUuid = args["_rjduPageUuid"];
          args.removeWhere((key, value) => key == "_rjduPageUuid");
          DynamicPage? pageByUuid = NavigatorApp.getPageByUuid(pageUuid);
          dynamic result;
          if (pageByUuid != null) {
            result = sysInvoke(item.key, args, pageByUuid.dynamicUIBuilderContext, true);
          } else {
            Util.log("DynamicInvoke.onMessage() DynamicPage($pageByUuid) not found in NavigatorApp",
                type: "error", stack: true);
          }
          if (result == null) {
            return null;
          }
          return result is String ? result : json.encode(result);
        } catch (e, stacktrace) {
          Util.log("DynamicInvoke.onMessage() args: $args; Error: $e", stackTrace: stacktrace, type: "error");
        }
      });
    }
    //Global.js нельзя перекатывать, так как собьются все регистрации RouterMap
    // Поэтому DataSource().subscribeUniqueContent не про него
    for (AssetsDataItem assetsDataItem in AssetsData().list) {
      if (assetsDataItem.name == "global.js") {
        safeEval("${assetsDataItem.data}\nbridge.debug = ${GlobalSettings().debug ? 'true' : 'false'};", "global.js");
      }
    }
    for (AssetsDataItem assetsDataItem in AssetsData().getJsAutoImportSorted()) {
      if (assetsDataItem.type == DataType.js && assetsDataItem.name.endsWith(".ai.js")) {
        safeEval(assetsDataItem.data, assetsDataItem.name);
        DataSource().subscribeUniqueContent(assetsDataItem.name, (uuid, data) {
          if (data != null && data.containsKey("js") && data["js"] != assetsDataItem.data) {
            assetsDataItem.data = data["js"]; //Что бы не было проблем
            safeEval(data["js"], uuid);
          }
        }, false, assetsDataItem.data);
      }
    }
  }

  void safeEval(String jsCode, String scriptUuid) {
    Util.p("js import $scriptUuid");
    String js = """
          try {
            if(bridge != undefined){
              bridge.scriptUuid = '$scriptUuid';
              bridge.args = {"method":"runtime"};
            }
            $jsCode
          } catch(e) {
            console.log('JavaScript init($scriptUuid) exception: ' + e);
          }
        """;
    javascriptRuntime?.evaluate(js);
  }

  DynamicUIBuilderContext changeContext(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.containsKey("changeContext")) {
      if (args["changeContext"] == "lastPage" && NavigatorApp.getLast() != null) {
        dynamicUIBuilderContext = NavigatorApp.getLast()!.dynamicUIBuilderContext;
      } else {
        dynamicUIBuilderContext = NavigatorApp.getPageByUuid(args["changeContext"])!.dynamicUIBuilderContext;
      }
    }
    return dynamicUIBuilderContext;
  }

  dynamic sysInvokeType(Type handler, Map<String, dynamic> inArgs, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool jsContext = false]) {
    return sysInvoke(handler.toString().replaceAll("Handler", ""), inArgs, dynamicUIBuilderContext);
  }

  dynamic sysInvoke(String handler, Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool jsContext = false]) {
    try {
      if (this.handler.containsKey(handler)) {
        args = Util.getMutableMap(args);
        Template.compileTemplateList(args, dynamicUIBuilderContext);
        dynamicUIBuilderContext = changeContext(args, dynamicUIBuilderContext);

        String log = "";
        if (kDebugMode && GlobalSettings().debug) {
          log = "DynamicInvoke.sysInvoke($handler, $args)\ntemplate:\n";
          log += "${Util.jsonPretty(args)}\n";
          if (jsContext) {
            log += "from JsInvoke\n";
          }
        }
        dynamic result = Function.apply(this.handler[handler]!, [args, dynamicUIBuilderContext]);
        if (kDebugMode && GlobalSettings().debug) {
          if (args.containsKey("printResult")) {
            Util.log("$log => $result");
          }
        }
        if (result != null) {
          return result;
        }
      } else {
        Util.log("DynamicInvoke.call() handler[$handler] undefined", type: "error");
      }
    } catch (error, stackTrace) {
      Util.log("DynamicInvoke.sysInvoke($handler, $args, $jsContext); Error: $error", stackTrace: stackTrace, type: "error");
    }
    return null;
  }

  void jsRouter(String uuid, Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    args = Util.getMutableMap(args);
    Template.compileTemplateList(args, dynamicUIBuilderContext);
    dynamicUIBuilderContext = changeContext(args, dynamicUIBuilderContext);
    _eval2(
        "Router:$uuid",
        "bridge.runRouter('$uuid');",
        {
          "args": args,
          "context": dynamicUIBuilderContext.data,
          "contextMap": dynamicUIBuilderContext.dynamicPage.getContextMap(),
          "state": dynamicUIBuilderContext.dynamicPage.stateData.getAllData(),
          "pageArgs": dynamicUIBuilderContext.dynamicPage.arguments
        },
        dynamicUIBuilderContext);
  }

  void jsInvoke(
    String uuid,
    Map<String, dynamic> args,
    DynamicUIBuilderContext dynamicUIBuilderContext, [
    bool includeContext = false,
    bool includeContextMap = false,
    bool includeStateData = false,
    bool includePageArgument = false,
  ]) {
    args = Util.getMutableMap(args);
    Template.compileTemplateList(args, dynamicUIBuilderContext);

    if (args.containsKey("includeAll") && args["includeAll"] == true) {
      includeStateData = true;
      includeContextMap = true;
      includeContext = true;
      includePageArgument = true;
    } else {
      if (args.containsKey("includeStateData") && args["includeStateData"] == true) {
        includeStateData = true;
      }
      if (args.containsKey("includeContextMap") && args["includeContextMap"] == true) {
        includeContextMap = true;
      }
      if (args.containsKey("includeContext") && args["includeContext"] == true) {
        includeContext = true;
      }
      if (args.containsKey("includePageArgument") && args["includePageArgument"] == true) {
        includePageArgument = true;
      }
    }

    dynamicUIBuilderContext = changeContext(args, dynamicUIBuilderContext);
    DataSource().get(uuid, (uuid, data) {
      if (data != null && data.containsKey(DataType.js.name)) {
        bool pretty = false;
        _eval(
          uuid,
          data[DataType.js.name],
          Util.jsonEncode(args, pretty),
          includeContext ? Util.jsonEncode(dynamicUIBuilderContext.data, pretty) : "",
          includeContextMap ? Util.jsonEncode(dynamicUIBuilderContext.dynamicPage.getContextMap(), pretty) : "",
          includeStateData ? Util.jsonEncode(dynamicUIBuilderContext.dynamicPage.stateData.getAllData(), pretty) : "",
          includePageArgument ? Util.jsonEncode(dynamicUIBuilderContext.dynamicPage.arguments, pretty) : "",
          dynamicUIBuilderContext,
        );
      } else {
        Util.p("DynamicJS.eval() DataSource.get($uuid) undefined");
      }
    });
  }

  String? _eval(String scriptUuid, String js, String args, String context, String contextMap, String state,
      String pageArgs, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.isNotEmpty) {
      args = "bridge.args = $args;";
    }
    if (context.isNotEmpty) {
      context = "bridge.context = $context;";
    }
    if (contextMap.isNotEmpty) {
      contextMap = "bridge.contextMap = $contextMap;";
    }
    if (state.isNotEmpty) {
      state = "bridge.state = $state;";
    }
    if (pageArgs.isNotEmpty) {
      pageArgs = "bridge.pageArgs = $pageArgs;";
    }
    String jsInit = """
        bridge.clearAll();
        bridge.pageUuid = '${dynamicUIBuilderContext.dynamicPage.uuid}';
        bridge.unique = '${Storage().get("unique", "")}';
        bridge.scriptUuid = '$scriptUuid';
        bridge.orientation = '${GlobalSettings().orientation}';
        bridge.pageActive = ${dynamicUIBuilderContext.dynamicPage == NavigatorApp.getLast() ? "true" : "false"};
//--------------------------------------------------------
$args
//--------------------------------------------------------
$context
//--------------------------------------------------------
$contextMap
//--------------------------------------------------------
$state
//--------------------------------------------------------
$pageArgs
//--------------------------------------------------------

    """;

    String tryBlock = """
      try {
        $jsInit
        $js
      } catch(e) {
        bridge.log('JavaScript v1 exception: ' + e);        
      }
    """;
    return javascriptRuntime!.evaluate(tryBlock).stringResult;
  }

  String? _eval2(String scriptUuid, String jsCode, Map<String, dynamic> bridgeContext,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    String bridgeInit = """
        bridge.clearAll();
        bridge.pageUuid = '${dynamicUIBuilderContext.dynamicPage.uuid}';
        bridge.unique = '${Storage().get("unique", "")}';
        bridge.scriptUuid = '$scriptUuid';
        bridge.orientation = '${GlobalSettings().orientation}';
        bridge.pageActive = ${dynamicUIBuilderContext.dynamicPage == NavigatorApp.getLast() ? "true" : "false"};
        bridge.setContext(${Util.jsonEncode(bridgeContext, true)});
    """;

    String tryBlock = """
      try {
        $bridgeInit
        $jsCode
      } catch(e) {
        bridge.log('JavaScript v2 exception: ' + e);        
      }
    """;
    return javascriptRuntime!.evaluate(tryBlock).stringResult;
  }
}

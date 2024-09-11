import 'dart:convert';
import '../../db/data_source.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class DbQueryHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    bool debug = false;
    if (args.containsKey("debug")) {
      debug = args["debug"];
    }
    if (Util.containsKeys(args, ["sql", "args"])) {
      if (debug) {
        Util.p("DbQueryHandler().handle($args)");
      }
      DataSource().db.rawQuery(args["sql"], args["args"]).then((value) {
        if (debug) {
          Util.p("RESULT rawQuery: $value");
        }
        try {
          doPostBack(args, dynamicUIBuilderContext, "fetchDb", updateResult(value), debug);
        } catch (error, stackTrace) {
          Util.log("DbQueryHandler.handle() args: $args; value: $value; Error: $error", stackTrace: stackTrace, type: "error");
        }
      }).onError((error, stackTrace) {
        Util.log("DbQueryHandler.handle(); Error: $error", stackTrace: stackTrace, type: "error");
      });
    } else if (Util.containsKeys(args, ["multiple"])) {
      if (debug) {
        Util.p("DbQueryHandler().handle($args)");
      }
      multiple(args, dynamicUIBuilderContext, debug);
    } else {
      Util.p("SetStateDataHandler not contains Keys: [sql, args | multiple] in args: $args");
    }
  }

  void multiple(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext, bool debug) async {
    List<dynamic> resultSelect = [];
    for (Map<String, dynamic> queryObject in args["multiple"]) {
      List<Map<String, dynamic>> res = await DataSource().db.rawQuery(queryObject["sql"], queryObject["args"]);
      resultSelect.add(updateResult(res));
    }
    doPostBack(args, dynamicUIBuilderContext, "fetchDb", resultSelect, debug);
  }

  List<Map<String, Object?>> updateResult(List<Map<String, Object?>> resultList) {
    List<Map<String, Object?>> newList = [];
    for (Map<String, Object?> item in resultList) {
      Map<String, dynamic> newItem = Util.getMutableMap(item);
      if (newItem["value_data"] != null && newItem["type_data"] != null) {
        if (Util.dataTypeValueOf(newItem["type_data"] as String).isJson()) {
          newItem["value_data"] = json.decode(item["value_data"] as String);
        }
      }
      newList.add(newItem);
    }
    return newList;
  }

  void doPostBack(
    Map<String, dynamic> args,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    String key,
    dynamic resultSelect,
    bool debug,
  ) {
    if (args.containsKey("setState")) {
      dynamicUIBuilderContext.dynamicPage.stateData.set(null, args["stateKey"], resultSelect);
    }
    if (args.containsKey("onFetch")) {
      var onFetch = args["onFetch"] as Map;
      if (!onFetch.containsKey("args")) {
        onFetch["args"] = {};
      }
      args["onFetch"]["args"]["fetchDb"] = resultSelect;
      if (debug) {
        Util.p("clickStatic: args: ${Util.jsonPretty(args)}");
      }
      AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onFetch");
    }
  }
}

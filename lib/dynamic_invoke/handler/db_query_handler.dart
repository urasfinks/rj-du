import 'dart:convert';
import '../../db/data_source.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class DbQueryHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["sql", "args"])) {
      DataSource().db.rawQuery(args["sql"], args["args"]).then((value) {
        try {
          doPostBack(args, dynamicUIBuilderContext, "fetchDb", updateResult(value));
        } catch (error, stackTrace) {
          Util.printStackTrace("DbQueryHandler.handle() args: $args; value: $value", error, stackTrace);
        }
      }).onError((error, stackTrace) {
        Util.printStackTrace("DbQueryHandler.handle()", error, stackTrace);
      });
    } else if (Util.containsKeys(args, ["multiple"])) {
      multiple(args, dynamicUIBuilderContext);
    } else {
      Util.p("SetStateDataHandler not contains Keys: [sql, args | multiple] in args: $args");
    }
  }

  void multiple(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) async {
    List<dynamic> resultSelect = [];
    for (Map<String, dynamic> queryObject in args["multiple"]) {
      List<Map<String, dynamic>> res = await DataSource().db.rawQuery(queryObject["sql"], queryObject["args"]);
      resultSelect.add(updateResult(res));
    }
    doPostBack(args, dynamicUIBuilderContext, "fetchDb", resultSelect);
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
      Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext, String key, dynamic resultSelect) {
    if (args.containsKey("setState")) {
      dynamicUIBuilderContext.dynamicPage.stateData.set(null, args["stateKey"], resultSelect);
    }
    if (args.containsKey("onFetch")) {
      var onFetch = args["onFetch"] as Map;
      if (!onFetch.containsKey("args")) {
        onFetch["args"] = {};
      }
      args["onFetch"]["args"]["fetchDb"] = resultSelect;
      AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onFetch");
    }
  }
}

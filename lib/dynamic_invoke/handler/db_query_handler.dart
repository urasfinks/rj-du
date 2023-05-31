import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../db/data_source.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class DbQueryHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['sql', 'args'])) {
      DataSource().db.rawQuery(args['sql'], args['args']).then((value) {
        List<Map<String, Object?>> newList = [];
        for (Map<String, Object?> item in value) {
          Map<String, dynamic> newItem = Util.getMutableMap(item);
          if (newItem["value_data"] != null) {
            if (DataSource().isJsonDataType(Util.dataTypeValueOf(newItem["type_data"] as String))) {
              newItem["value_data"] = json.decode(item["value_data"] as String);
            }
          }
          newList.add(newItem);
        }
        if (args.containsKey('stateKey')) {
          dynamicUIBuilderContext.dynamicPage.setStateData(args['stateKey'], newList);
        }
        if (args.containsKey("onFetch")) {
          var onFetch = args["onFetch"] as Map;
          if (!onFetch.containsKey("args")) {
            onFetch["args"] = {};
          }
          args["onFetch"]["args"]["fetchDb"] = newList;
          AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onFetch");
        }
      });
    } else {
      if (kDebugMode) {
        print("SetStateDataHandler not contains Keys: [sql, args] in args: $args");
      }
    }
  }
}

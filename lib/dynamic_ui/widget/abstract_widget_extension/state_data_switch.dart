import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/abstract_extension.dart';
import 'package:rjdu/subscribe_reload_group.dart';

import '../../dynamic_ui_builder_context.dart';

class StateDataSwitch extends AbstractExtension {
  static void extend(
      Map<String, dynamic> child, DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    String key = child["key"];

    String value = dynamicUIBuilderContext.dynamicPage.stateData.value[key] ?? "default";
    List<dynamic> children = child["children"];
    Map<String, dynamic> map = {};
    for (Map<String, dynamic> item in children) {
      if (item.containsKey("case")) {
        map[item["case"]] = item;
      } else {
        if (kDebugMode) {
          print("extensionStateDataSwitch item key 'case' not exist");
        }
      }
    }
    bool flagAdd = false;
    if (map.containsKey(value)) {
      if (map[value].containsKey("uuid_data")) {
        dynamicUIBuilderContext.dynamicPage.subscribeToReload(SubscribeReloadGroup.uuid, map[value]["uuid_data"]);
      }
      result.add(map[value]);
      flagAdd = true;
    }
    if (!flagAdd && map.containsKey("default")) {
      result.add(map["default"]);
      flagAdd = true;
    }
    if (!flagAdd) {
      if (kDebugMode) {
        print("extensionStateDataSwitch not found 'case' =  $value || default");
      }
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/abstract_extension.dart';

import '../../dynamic_ui_builder_context.dart';

class StateDataSwitch extends AbstractExtension {
  static void extend(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    String key = child["key"];

    //Будем прихранивать неявно объявленные uuid, что бы небыло лишних перерисовок страницы
    //Если это повторная отрисовка, данные, которые были на прошлом шагу могли поменятся
    //Поэтому удалим их и потом заново добавим уже обновлённые
    AbstractExtension.removeLastShadowUuid(key, dynamicUIBuilderContext);
    String value =
        dynamicUIBuilderContext.dynamicPage.stateData.value[key] ?? "default";
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
    if (map.containsKey(value)) {
      if (map[value].containsKey("uuid_data")) {
        dynamicUIBuilderContext.dynamicPage
            .addShadowUuid(map[value]["uuid_data"]);
      }
      result.add(map[value]);
    } else {
      if (kDebugMode) {
        print("extensionStateDataSwitch not found 'case' =  $value");
      }
    }
  }
}

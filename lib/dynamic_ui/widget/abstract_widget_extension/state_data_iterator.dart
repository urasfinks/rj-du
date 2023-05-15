import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/abstract_extension.dart';

import '../../dynamic_ui_builder_context.dart';

class StateDataIterator extends AbstractExtension {
  static void extend(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    bool divider = child.containsKey("Divider");
    String key = child["key"];
    //Будем прихранивать неявно объявленные uuid, что бы небыло лишних перерисовок страницы
    //Если это повторная отрисовка, данные, которые были на прошлом шагу могли поменятся
    //Поэтому удалим их и потом заново добавим уже обновлённые
    AbstractExtension.removeLastShadowUuid(key, dynamicUIBuilderContext);
    dynamic value = dynamicUIBuilderContext.dynamicPage.stateData.value[key];
    bool add = false;
    if (value != null) {
      List<dynamic> list = value as List<dynamic>;
      for (Map<String, dynamic> item in list) {
        Map<String, dynamic> map = {};
        map.addAll(child["template"] ??
            item["template"]); //Шаблон можно заложить в данные
        map["context"] = item;
        if (item.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.addShadowUuid(item["uuid_data"]);
        }
        add = true;
        result.add(map);
        if (divider && list.last != item) {
          result.add(child["Divider"]);
        }
      }
    }
    //Если небыло ничего добавлено в результирующий список, добавим предустановленный ifDataEmpty если есть
    if (!add && child.containsKey("ifDataEmpty")) {
      result.add(child["ifDataEmpty"]);
    }
  }
}

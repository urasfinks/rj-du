import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/abstract_extension.dart';
import 'package:rjdu/subscribe_reload_group.dart';

import '../../dynamic_ui_builder_context.dart';

class StateDataIterator extends AbstractExtension {
  static void extend(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    bool divider = child.containsKey("Divider");
    dynamic value = dynamicUIBuilderContext.dynamicPage.stateData.get(child["state"], child["key"], []);
    bool add = false;
    if (value != null) {
      List<dynamic> list = value as List<dynamic>;
      for (Map<String, dynamic> item in list) {
        Map<String, dynamic> map = {};
        map.addAll(child["template"] ??
            item["template"]); //Шаблон можно заложить в данные
        map["context"] = item;
        if (item.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.subscribeToReload(SubscribeReloadGroup.uuid, item["uuid_data"]);
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

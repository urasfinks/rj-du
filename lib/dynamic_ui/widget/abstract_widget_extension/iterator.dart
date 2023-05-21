import '../../dynamic_ui_builder_context.dart';
import 'abstract_extension.dart';
//import 'iterator_theme/button_group.dart';

class Iterator extends AbstractExtension {
  static Map<String, Map<String, dynamic>> theme = {
    //"ButtonGroup": ButtonGroup().getTheme()
  };

  static void extend(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    String dataType = child["dataType"];
    dynamic value;
    switch (dataType) {
      case "state":
        String key = child["key"];
        //Будем прихранивать неявно объявленные uuid, что бы небыло лишних перерисовок страницы
        //Если это повторная отрисовка, данные, которые были на прошлом шагу могли поменятся
        //Поэтому удалим их и потом заново добавим уже обновлённые
        AbstractExtension.removeLastShadowUuid(key, dynamicUIBuilderContext);
        value = dynamicUIBuilderContext.dynamicPage.stateData.value[key];
        break;
      case "list":
        value = child["list"];
        break;
    }

    if (child.containsKey("theme")) {
      if (theme.containsKey(child["theme"])) {
        child.addAll(theme[child["theme"]]!);
      } else {
        result.add({
          "flutterType": "Text",
          "label": "Theme [${child["theme"]}] is not defined"
        });
        return;
      }
    }
    bool templateDivider = child.containsKey("template_divider");
    bool add = false;
    if (value != null) {
      List<dynamic> list = value as List<dynamic>;
      for (Map<String, dynamic> item in list) {
        Map<String, dynamic> map = {};
        String seqType;
        if (item.containsKey("customSeqType")) {
          seqType = item["customSeqType"];
        } else if (list.length == 1) {
          seqType = "template_single";
        } else if (list.first == item) {
          seqType = "template_first";
        } else if (list.last == item) {
          seqType = "template_last";
        } else {
          seqType = "template_middle";
        }
        map.addAll(item[seqType] ??
            item["template"] ??
            child[seqType] ??
            child["template"]); //Шаблон можно заложить в данные
        map["context"] = item;

        if (item.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.addShadowUuid(item["uuid_data"]);
        }
        add = true;
        result.add(map);
        if (templateDivider && list.last != item) {
          result.add(child["template_divider"]);
        }
      }
    }
    //Если небыло ничего добавлено в результирующий список, добавим предустановленный ifDataEmpty если есть
    if (!add && child.containsKey("ifDataEmpty")) {
      result.add(child["ifDataEmpty"]);
    }
  }
}

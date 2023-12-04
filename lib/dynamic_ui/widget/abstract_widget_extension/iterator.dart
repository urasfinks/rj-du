import 'package:rjdu/subscribe_reload_group.dart';

import '../../../util.dart';
import '../../../util/template.dart';
import '../../dynamic_ui_builder_context.dart';
import 'abstract_extension.dart';

class Iterator extends AbstractExtension {
  static Map<String, Map<String, dynamic>> theme = {
    //"ButtonGroup": ButtonGroup().getTheme()
  };

  static void extend(
      Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    String dataType = parsedJson["dataType"];
    dynamic listData;
    switch (dataType) {
      case "state":
        listData = dynamicUIBuilderContext.dynamicPage.stateData.get(parsedJson["state"], parsedJson["key"], []);
        break;
      case "list":
        listData = parsedJson["list"] ?? [];
        break;
    }

    if (parsedJson.containsKey("theme")) {
      if (theme.containsKey(parsedJson["theme"])) {
        parsedJson.addAll(theme[parsedJson["theme"]]!);
      } else {
        result.add({"flutterType": "Text", "label": "Theme [${parsedJson["theme"]}] is not defined"});
        return;
      }
    }
    bool templateDivider = parsedJson.containsKey("templateDivider");
    bool add = false;
    if (listData != null) {
      List<dynamic> list = listData as List<dynamic>;
      int counter = 0;
      for (Map<String, dynamic> data in list) {
        Map<String, dynamic> newUIElement = {};
        String seqTemplate;
        if (data.containsKey("templateCustom")) {
          seqTemplate = data["templateCustom"];
        } else if (list.length == 1) {
          seqTemplate = "templateSingle";
        } else if (list.first == data) {
          seqTemplate = "templateFirst";
        } else if (list.last == data) {
          seqTemplate = "templateLast";
        } else {
          seqTemplate = "templateMiddle";
        }
        //Если не обернуть в свой объект, renderTemplateList применится только к первому
        //Все остальные потеряют первичный шаблон, так как он будет уже заменён на значение
        newUIElement.addAll(Util.getMutableMap(data[seqTemplate] ??
            data["template"] ??
            parsedJson[seqTemplate] ??
            parsedJson["template"])); //Шаблон можно заложить в данные

        //Расширение данных из родителя
        if (parsedJson.containsKey("extendDataElement")) {
          data.addAll(Util.getMutableMap(parsedJson["extendDataElement"]));
        }
        newUIElement["context"] = {
          "key": "Iterator${counter++}",
          "data": Util.renderTemplate(data, RenderTemplateType.current, dynamicUIBuilderContext)
        };

        if (data.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.subscribeToReload(SubscribeReloadGroup.uuid, data["uuid_data"]);
        }
        add = true;
        result.add(newUIElement);
        if (templateDivider && list.last != data) {
          result.add(parsedJson["templateDivider"]);
        }
      }
    }
    //Если небыло ничего добавлено в результирующий список, добавим предустановленный ifDataEmpty если есть
    if (!add && parsedJson.containsKey("ifDataEmpty")) {
      result.add(parsedJson["ifDataEmpty"]);
    }
  }
}

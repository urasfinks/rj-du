import 'package:rjdu/subscribe_reload_group.dart';

import '../../../util.dart';
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
    bool templateDivider = parsedJson.containsKey("template_divider");
    bool add = false;
    if (listData != null) {
      List<dynamic> list = listData as List<dynamic>;
      int counter = 0;
      for (Map<String, dynamic> data in list) {
        Map<String, dynamic> newUIElement = {};
        String seqType;
        if (data.containsKey("customSeqType")) {
          seqType = data["customSeqType"];
        } else if (list.length == 1) {
          seqType = "template_single";
        } else if (list.first == data) {
          seqType = "template_first";
        } else if (list.last == data) {
          seqType = "template_last";
        } else {
          seqType = "template_middle";
        }
        newUIElement.addAll(data[seqType] ??
            data["template"] ??
            parsedJson[seqType] ??
            parsedJson["template"]); //Шаблон можно заложить в данные

        if (parsedJson.containsKey("extendDataElement")) {
          data.addAll(Util.getMutableMap(parsedJson["extendDataElement"]));
        }
        newUIElement["context"] = {
          "key": "Iterator${counter++}",
          "data": Util.templateArguments(data, dynamicUIBuilderContext)
        };

        if (data.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.subscribeToReload(SubscribeReloadGroup.uuid, data["uuid_data"]);
        }
        add = true;
        result.add(newUIElement);
        if (templateDivider && list.last != data) {
          result.add(parsedJson["template_divider"]);
        }
      }
    }
    //Если небыло ничего добавлено в результирующий список, добавим предустановленный ifDataEmpty если есть
    if (!add && parsedJson.containsKey("ifDataEmpty")) {
      result.add(parsedJson["ifDataEmpty"]);
    }
  }
}

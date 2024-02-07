import 'package:rjdu/dynamic_ui/type_parser.dart';
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
        listData = dynamicUIBuilderContext.dynamicPage.stateData.get(parsedJson["state"], parsedJson["key"], null);
        break;
      case "list":
        listData = parsedJson["list"];
        break;
    }
    Template.compileTemplateList(parsedJson, dynamicUIBuilderContext);
    if (parsedJson.containsKey("theme")) {
      if (theme.containsKey(parsedJson["theme"])) {
        parsedJson.addAll(theme[parsedJson["theme"]]!);
      } else {
        result.add({"flutterType": "Text", "label": "Theme \"${parsedJson["theme"]}\" is not defined"});
        return;
      }
    }
    bool templateDivider = parsedJson.containsKey("templateDivider");
    bool add = false;
    if (listData != null) {
      //TODO: Что-то не так с расширением extendDataElement - остаются поля в state
      List<dynamic> list = List<dynamic>.from(listData);
      //List<dynamic> list = listData as List<dynamic>;
      int counter = 0;
      for (Map<String, dynamic> data in list) {
        //Расширение данных из родителя
        if (parsedJson.containsKey("extendDataElement")) {
          data.addAll(Util.getMutableMap(parsedJson["extendDataElement"]));
        }

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

        data["iteratorIndex"] = counter;
        if (data.containsKey("dataContext")) {
          Template.compileTemplateList(data, dynamicUIBuilderContext.cloneWithNewData(data, "IteratorDataContext"));
        } else {
          Template.compileTemplateList(data, dynamicUIBuilderContext);
        }

        Map<String, dynamic>? templateElement =
            data[seqTemplate] ?? data["template"] ?? parsedJson[seqTemplate] ?? parsedJson["template"];

        if (templateElement != null) {
          //Если не обернуть в свой объект, compileTemplateList применится только к первому
          //Все остальные потеряют первичный шаблон, так как он будет уже заменён на значение
          newUIElement.addAll(Util.getMutableMap(templateElement)); //Шаблон можно заложить в данные

          if (!newUIElement.containsKey("context")) {
            //Бывает такое, что шаблон уже предусматривает контекст
            newUIElement["context"] = {
              "key": "Iterator$counter",
              "data": data,
            };
          }
          if (newUIElement["context"]["data"].containsKey("visibility")) {
            bool visibility = TypeParser.parseBool(newUIElement["context"]["data"]["visibility"]) ?? true;
            if (visibility == false) {
              continue;
            }
          }
          result.add(newUIElement);
        } else {
          result.add(data);
        }
        if (data.containsKey("uuid_data")) {
          dynamicUIBuilderContext.dynamicPage.subscribeToReload(SubscribeReloadGroup.uuid, data["uuid_data"]);
        }
        add = true;
        if (templateDivider && list.last != data) {
          result.add(parsedJson["templateDivider"]);
        }
        counter++;
      }
    }
    // Если небыло ничего добавлено в результирующий список, добавим предустановленный ifDataEmpty если есть
    // Для того, что бы отоброзить пустой блок, надо что бы listData хотябы существовало, что бы можно было сказать
    // что данные пустые, иначе при инициализации будут моргания
    if (!add && parsedJson.containsKey("ifDataEmpty") && listData != null) {
      result.add(parsedJson["ifDataEmpty"]);
    }
  }
}

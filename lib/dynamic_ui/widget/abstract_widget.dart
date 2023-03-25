import '../dynamic_ui.dart';
import '../dynamic_ui_builder_context.dart';
import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../util.dart';

abstract class AbstractWidget {
  dynamic get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext);

  static dynamic getValueStatic(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    dynamic selector = key == null ? parsedJson : ((parsedJson.containsKey(key)) ? parsedJson[key] : defaultValue);
    if (selector.runtimeType.toString() == "String") {
      selector = Util.template(selector, dynamicUIBuilderContext);
    }
    return selector;
  }

  dynamic getValue(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    return getValueStatic(parsedJson, key, defaultValue, dynamicUIBuilderContext);
  }

  dynamic render(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    return DynamicUI.render(parsedJson, key, defaultValue, dynamicUIBuilderContext);
  }

  dynamic renderList(
    Map<String, dynamic> parsedJson,
    String key,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (!parsedJson.containsKey(key)) {
      return null;
    }
    String keyDefaultBeforeUpdate = "${key}DefaultBeforeUpdate";
    if (parsedJson.containsKey(keyDefaultBeforeUpdate)) {
      parsedJson[key] = updateList(parsedJson[keyDefaultBeforeUpdate] as List, dynamicUIBuilderContext);
    } else {
      List saveList = [];
      saveList.addAll(parsedJson[key]);
      parsedJson[keyDefaultBeforeUpdate] = saveList;
      parsedJson[key] = updateList(saveList, dynamicUIBuilderContext);
    }

    return DynamicUI.renderList(parsedJson, key, dynamicUIBuilderContext);
  }

  List updateList(
    List list,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    List<dynamic> result = [];
    for (var element in list) {
      Map<String, dynamic> el = element as Map<String, dynamic>;
      if (el.containsKey("ChildrenExtension") && el["ChildrenExtension"] == "StateDataIterator") {
        bool divider = el.containsKey("Divider");
        //print("StateDataIterator(${el["key"]}) : ${dynamicUIBuilderContext.dynamicPage.stateData.value}");
        String key = el["key"];
        //Будем прихранивать неявно объявленные uuid, для последующего удаления, что бы небыло лишних перерисовок страницы
        List earlyUuids = dynamicUIBuilderContext.dynamicPage.getProperty(key, []) as List;
        for (String earlyUuid in earlyUuids) {
          dynamicUIBuilderContext.dynamicPage.removeShadowUuid(earlyUuid);
        }
        dynamic value = dynamicUIBuilderContext.dynamicPage.stateData.value[key];
        bool add = false;
        if (value != null) {
          List<dynamic> extraList = value as List<dynamic>;
          for (Map<String, dynamic> data in extraList) {
            Map<String, dynamic> newElement = {};
            newElement.addAll(el["template"] ?? data["template"]); //Шаблон можно заложить в данные
            newElement["context"] = data;
            if (data.containsKey("uuid_data")) {
              dynamicUIBuilderContext.dynamicPage.addShadowUuid(data["uuid_data"]);
            }
            add = true;
            result.add(newElement);
            if (divider && extraList.last != data) {
              result.add(el["Divider"]);
            }
          }
        }
        if(!add && el.containsKey("ifDataEmpty")){
          result.add(el["ifDataEmpty"]);
        }
      } else {
        result.add(element);
      }
    }
    return result;
  }

  static void clickStatic(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed"]) {
    Map<String, dynamic>? settings = getValueStatic(parsedJson, key, null, dynamicUIBuilderContext);
    if (settings != null) {
      if (settings.containsKey('jsInvoke')) {
        DynamicInvoke().jsInvoke(settings['jsInvoke'], settings['args'], dynamicUIBuilderContext);
      } else if (settings.containsKey('sysInvoke')) {
        DynamicInvoke().sysInvoke(settings['sysInvoke'], settings['args'] ?? {}, dynamicUIBuilderContext);
      }
    }
  }

  void click(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext, [String key = "onPressed"]) {
    clickStatic(parsedJson, dynamicUIBuilderContext, key);
  }
}

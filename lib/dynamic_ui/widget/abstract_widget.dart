import 'package:flutter/foundation.dart';

import '../dynamic_ui.dart';
import '../dynamic_ui_builder_context.dart';
import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../util.dart';

abstract class AbstractWidget {
  dynamic get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext);

  static dynamic getValueStatic(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    dynamic selector = key == null
        ? parsedJson
        : ((parsedJson.containsKey(key)) ? parsedJson[key] : defaultValue);
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
    return getValueStatic(
        parsedJson, key, defaultValue, dynamicUIBuilderContext);
  }

  dynamic render(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    return DynamicUI.render(
        parsedJson, key, defaultValue, dynamicUIBuilderContext);
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
      parsedJson[key] = updateList(
          parsedJson[keyDefaultBeforeUpdate] as List, dynamicUIBuilderContext);
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
      if (el.containsKey("ChildrenExtension")) {
        switch (el["ChildrenExtension"]) {
          case "StateDataIterator":
            extensionStateDataIterator(el, dynamicUIBuilderContext, result);
            break;
          case "StateDataSwitch":
            extensionStateDataSwitch(el, dynamicUIBuilderContext, result);
            break;
        }
      } else {
        result.add(element);
      }
    }
    return result;
  }

  static void extensionStateDataSwitch(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    String key = child["key"];

    //Будем прихранивать неявно объявленные uuid, что бы небыло лишних перерисовок страницы
    //Если это повторная отрисовка, данные, которые были на прошлом шагу могли поменятся
    //Поэтому удалим их и потом заново добавим уже обновлённые
    removeLastShadowUuid(key, dynamicUIBuilderContext);
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

  static void extensionStateDataIterator(Map<String, dynamic> child,
      DynamicUIBuilderContext dynamicUIBuilderContext, List<dynamic> result) {
    bool divider = child.containsKey("Divider");
    String key = child["key"];
    //Будем прихранивать неявно объявленные uuid, что бы небыло лишних перерисовок страницы
    //Если это повторная отрисовка, данные, которые были на прошлом шагу могли поменятся
    //Поэтому удалим их и потом заново добавим уже обновлённые
    removeLastShadowUuid(key, dynamicUIBuilderContext);
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

  static void removeLastShadowUuid(
      String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List earlyUuids =
        dynamicUIBuilderContext.dynamicPage.getProperty(key, []) as List;
    for (String earlyUuid in earlyUuids) {
      dynamicUIBuilderContext.dynamicPage.removeShadowUuid(earlyUuid);
    }
  }

  static void invoke(
    Map<String, dynamic>? settings,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (settings != null) {
      if (settings.containsKey('jsInvoke')) {
        DynamicInvoke().jsInvoke(
            settings['jsInvoke'], settings['args'], dynamicUIBuilderContext);
      } else if (settings.containsKey('sysInvoke')) {
        DynamicInvoke().sysInvoke(settings['sysInvoke'], settings['args'] ?? {},
            dynamicUIBuilderContext);
      } else if (settings.containsKey('list')) {
        List<dynamic> list = settings["list"];
        for (dynamic data in list) {
          invoke(data, dynamicUIBuilderContext);
        }
      }
    }
  }

  static void clickStatic(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed"]) {
    Future(() {
      Map<String, dynamic>? settings =
          getValueStatic(parsedJson, key, null, dynamicUIBuilderContext);
      invoke(settings, dynamicUIBuilderContext);
      return null;
    }).then((result) {}).catchError((error) {
      if (kDebugMode) {
        print("clickStatic exception: $error");
      }
    });
  }

  void click(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed"]) {
    clickStatic(parsedJson, dynamicUIBuilderContext, key);
  }
}

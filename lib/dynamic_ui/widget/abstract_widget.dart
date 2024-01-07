import 'dart:convert';

import 'package:rjdu/abstract_controller_wrap.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/state_data_iterator.dart';

import '../dynamic_ui.dart';
import '../dynamic_ui_builder_context.dart';
import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../util.dart';
import 'abstract_widget_extension/iterator.dart';
import 'abstract_widget_extension/state_data_switch.dart';
import 'package:flutter/material.dart';

abstract class AbstractWidget {
  dynamic get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext);

  static Map<String, dynamic> getStateControl(
      String state, DynamicUIBuilderContext dynamicUIBuilderContext, Map<String, dynamic> defaultState) {
    return dynamicUIBuilderContext.dynamicPage.stateData.getInstanceData(state, defaultState).value;
  }

  T getController<T>(
    Map<String, dynamic> parsedJson,
    String state,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    AbstractControllerWrap<T> Function() getDefault,
  ) {
    String controllerKey = getControllerKey(parsedJson, state, dynamicUIBuilderContext);
    AbstractControllerWrap? ctx = dynamicUIBuilderContext.dynamicPage.getPropertyFn(controllerKey, getDefault);
    return ctx!.getController();
  }

  clearController(Map<String, dynamic> parsedJson, String state, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String controllerKey = getControllerKey(parsedJson, state, dynamicUIBuilderContext);
    AbstractControllerWrap? ctx = dynamicUIBuilderContext.dynamicPage.getProperty(controllerKey, null);
    if (ctx != null) {
      ctx.dispose();
      dynamicUIBuilderContext.dynamicPage.properties.remove(controllerKey);
    }
  }

  String getControllerKey(Map<String, dynamic> parsedJson, state, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String controllerKey = parsedJson["controller"] ?? parsedJson["state"] ?? state;
    return Util.template(controllerKey, dynamicUIBuilderContext);
  }

  AbstractControllerWrap? getControllerWrap(
      Map<String, dynamic> parsedJson, String state, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return dynamicUIBuilderContext.dynamicPage
        .getProperty(getControllerKey(parsedJson, state, dynamicUIBuilderContext), null);
  }

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

  dynamic checkNullWidget(String className, Map<String, dynamic> parsedJson, dynamic resultWidget) {
    if (resultWidget == null) {
      return Text("$className.build() Return: $resultWidget; Must be Widget");
    }
    if (resultWidget != null && resultWidget.runtimeType.toString().contains("Map<String,")) {
      Util.p(
          "$className.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; input: $parsedJson; Must be Widget");
      return Text("$className.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
    }
    return resultWidget;
  }

  dynamic getValue(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    try {
      if (parsedJson.containsKey(key)) {
        return getValueStatic(parsedJson, key, defaultValue, dynamicUIBuilderContext);
      } else {
        return defaultValue;
      }
    } catch (e, stacktrace) {
      Util.printStackTrace(
          "AbstractWidget.getValue() key: $key; defaultValue: $defaultValue; parsedJson: $parsedJson", e, stacktrace);
    }
  }

  dynamic render(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    return DynamicUI.render(parsedJson, key, defaultValue, dynamicUIBuilderContext);
  }

  List<Widget> renderList(
    Map<String, dynamic> parsedJson,
    String key,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (!parsedJson.containsKey(key)) {
      return [];
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
      if (el.containsKey("ChildrenExtension")) {
        switch (el["ChildrenExtension"]) {
          case "StateDataIterator":
            StateDataIterator.extend(el, dynamicUIBuilderContext, result);
            break;
          case "StateDataSwitch":
            StateDataSwitch.extend(el, dynamicUIBuilderContext, result);
            break;
          case "Iterator":
            Iterator.extend(el, dynamicUIBuilderContext, result);
            break;
        }
      } else {
        result.add(element);
      }
    }
    return result;
  }

  static void invoke(
    Map<String, dynamic>? settings,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (settings != null) {
      if (settings.containsKey("jsInvoke")) {
        DynamicInvoke().jsInvoke(settings["jsInvoke"], settings["args"], dynamicUIBuilderContext);
      } else if (settings.containsKey("sysInvoke")) {
        DynamicInvoke().sysInvoke(settings["sysInvoke"], settings["args"] ?? {}, dynamicUIBuilderContext);
      } else if (settings.containsKey("list")) {
        List<dynamic> list = settings["list"];
        for (dynamic data in list) {
          invoke(data, dynamicUIBuilderContext);
        }
      }
    }
  }

  static void clickStatic(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed", Map<String, dynamic>? extendArgs]) {
    if (parsedJson.containsKey(key)) {
      Future(() {
        Map<String, dynamic>? settings;
        dynamic tmp = getValueStatic(parsedJson, key, null, dynamicUIBuilderContext);
        if (tmp == null || tmp == "") {
          return null;
        }
        if (tmp.runtimeType.toString().contains("Map")) {
          settings = tmp as Map<String, dynamic>?;
        } else {
          try {
            settings = json.decode(tmp) as Map<String, dynamic>?;
          } catch (e, stacktrace) {
            Util.printStackTrace(
                "AbstractWidget.clickStatic() key: $key; parsedJson: $parsedJson; tmp: $tmp; tmpType: ${tmp.runtimeType.toString()}",
                e,
                stacktrace);
          }
        }
        if (settings != null) {
          if (extendArgs != null) {
            Map<String, dynamic> newSettings = Util.getMutableMap(settings);
            if (!newSettings.containsKey("args")) {
              newSettings["args"] = {};
            }
            Util.merge(newSettings["args"], extendArgs);
            invoke(newSettings, dynamicUIBuilderContext);
          } else {
            invoke(settings, dynamicUIBuilderContext);
          }
        }
        return null;
      }).then((result) {}).catchError((error, stacktrace) {
        Util.printStackTrace("clickStatic", error, stacktrace);
      }).onError((error, stackTrace) {
        Util.printStackTrace("AbstractWidget.clickStatic()", error, stackTrace);
      });
    }
  }

  void click(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed"]) {
    clickStatic(parsedJson, dynamicUIBuilderContext, key);
  }
}

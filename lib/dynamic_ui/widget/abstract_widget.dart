import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget_extension/state_data_iterator.dart';
import 'package:rjdu/global_settings.dart';

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
      String key, DynamicUIBuilderContext dynamicUIBuilderContext, Map<String, dynamic> defaultState) {
    return dynamicUIBuilderContext.dynamicPage.stateData.getInstanceData(key, defaultState).value;
  }

  static dynamic getValueStatic(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    dynamicUIBuilderContext.parentTemplate = parsedJson;
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
      if (kDebugMode) {
        print(
            "$className.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; input: $parsedJson; Must be Widget");
      }
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
      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stacktrace,
          maxFrames: GlobalSettings().debugStackTraceMaxFrames,
          label:
              "AbstractWidget.getValue() Exception: $e; key: $key; defaultValue: $defaultValue; parsedJson: $parsedJson",
        );
      }
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
      [String key = "onPressed"]) {
    if (parsedJson.containsKey(key)) {
      Future(() {
        Map<String, dynamic>? settings;
        dynamic tmp = getValueStatic(parsedJson, key, null, dynamicUIBuilderContext);
        if (tmp == null) {
          return null;
        }
        if (tmp.runtimeType.toString().contains("Map")) {
          settings = tmp as Map<String, dynamic>?;
        } else {
          try {
            settings = json.decode(tmp) as Map<String, dynamic>?;
          } catch (e, stacktrace) {
            debugPrintStack(
              stackTrace: stacktrace,
              maxFrames: GlobalSettings().debugStackTraceMaxFrames,
              label:
              "AbstractWidget.clickStatic() Exception: $e; key: $key; parsedJson: $parsedJson",
            );
          }
        }
        if (settings != null) {
          invoke(settings, dynamicUIBuilderContext);
        }
        return null;
      }).then((result) {}).catchError((error, stacktrace) {
        if (kDebugMode) {
          print("clickStatic exception: $error $stacktrace");
        }
      });
    }
  }

  void click(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext,
      [String key = "onPressed"]) {
    clickStatic(parsedJson, dynamicUIBuilderContext, key);
  }
}

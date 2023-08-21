import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_invoke/handler/hide_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/show_handler.dart';
import 'package:rjdu/util/template.dart';
import 'package:rjdu/web_socket_service.dart';
import 'data_type.dart';
import 'db/data.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'store_value_notifier.dart';
import 'dynamic_ui/dynamic_ui.dart';
import 'navigator_app.dart';
import 'system_notify.dart';
import 'util.dart';
import 'db/data_source.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:uuid/uuid.dart';

import 'dynamic_ui/widget/abstract_widget.dart';

class DynamicPage extends StatefulWidget {
  late final Map<String, dynamic> arguments;
  final Map<String, dynamic> properties = {};
  final StoreValueNotifier storeValueNotifier = StoreValueNotifier();
  late final DynamicUIBuilderContext dynamicUIBuilderContext;
  final Map<String, DynamicUIBuilderContext> contextMap = {};
  BuildContext? context;
  late final Data stateData;
  final String uuid = const Uuid().v4();
  bool isRunConstructor = false;
  List<String> shadowUuidList = [];
  List<String> listUpdateUuidToReloadDynamicPage = [];
  _DynamicPage? dynamicPageSate;
  bool isDispose = false;

  DynamicPage(parseJson, {super.key}) {
    arguments = Util.getMutableMap(parseJson);
    Map<String, dynamic> stateDataValue = {};
    stateData = Data(uuid, stateDataValue, DataType.virtual, null);
    dynamicUIBuilderContext = DynamicUIBuilderContext(this, "root");
    dynamicUIBuilderContext.isRoot = true;
    SystemNotify().subscribe(SystemNotifyEnum.changeOrientation, onChangeOrientation);
  }

  void constructor() {
    if (!isRunConstructor) {
      isRunConstructor = true;
      if (arguments.containsKey("constructor") && arguments["constructor"].isNotEmpty) {
        AbstractWidget.clickStatic(arguments, dynamicUIBuilderContext, "constructor");
      }

      if (arguments.containsKey("socket") && arguments["socket"] == true) {
        WebSocketService().addListener(this);
      }

      if (arguments.containsKey("subscribeOnChangeUuid")) {
        List listUuid = arguments["subscribeOnChangeUuid"] as List;
        for (String uuid in listUuid) {
          DataSource().subscribe(uuid, onChangeUuid);
        }
      }
    }
  }

  void destructor() {
    onEvent("destructor", {});
    WebSocketService().removeListener(this);
    SystemNotify().emit(SystemNotifyEnum.changeViewport, "onHistoryPop");
    DataSource().unsubscribe(onChangeUuid);
    SystemNotify().unsubscribe(SystemNotifyEnum.changeOrientation, onChangeOrientation);
  }

  void onEvent(String key, Map<String, dynamic> args) {
    if (kDebugMode) {
      //print("DynamicPage.onEvent($key); args: $args");
    }
    if (arguments.containsKey(key)) {
      dynamic copyArgs = Util.getMutableMap(arguments);
      dynamic event = copyArgs[key] as Map<String, dynamic>;
      if (event.containsKey("args")) {
        Map<String, dynamic> eventArgs = event["args"];
        Util.merge(eventArgs, args);
      } else {
        event["args"] = args;
      }
      AbstractWidget.clickStatic(copyArgs, dynamicUIBuilderContext, key);
    }
  }

  void onChangeOrientation(String orientation) {
    onEvent("onChangeOrientation", {orientation: orientation});
  }

  void onChangeUuid(String uuid, Map<String, dynamic>? data) {
    onEvent("onChangeUuid", {"uuid": uuid, "data": data});
  }

  void onActive() {
    onEvent("onActive", {});
    renderFloatingActionButton();
  }

  void reloadWithoutSetState() {
    properties.clear(); //Что бы стереть TextFieldController при перезагрузке страницы
    isRunConstructor = false;
    constructor();
  }

  void reload() {
    properties.clear(); //Что бы стереть TextFieldController при перезагрузке страницы
    isRunConstructor = false;
    if (dynamicPageSate != null) {
      dynamicPageSate!.setState(() {});
    }
  }

  void setStateData(String key, dynamic value, [bool notifyDynamicPage = true]) {
    if (stateData.value[key] != value) {
      stateData.value[key] = value;
      DataSource().setData(stateData, notifyDynamicPage);
    }
  }

  void setStateDataMap(Map<String, dynamic> map, [bool notifyDynamicPage = true]) {
    bool change = false;
    for (MapEntry<String, dynamic> item in map.entries) {
      if (stateData.value[item.key] != item.value) {
        stateData.value[item.key] = item.value;
        change = true;
      }
    }
    if (change) {
      DataSource().setData(stateData, notifyDynamicPage);
    }
  }

  dynamic getStateData(String key, dynamic defaultValue, [insertIfNotExist = false]) {
    Map<String, dynamic> map = stateData.value;
    if (map.containsKey(key)) {
      return map[key];
    } else {
      if (insertIfNotExist && !map.containsKey(key)) {
        map[key] = defaultValue;
        return map[key];
      } else {
        return defaultValue;
      }
    }
  }

  void setProperty(String key, dynamic value) {
    properties[key] = value;
  }

  dynamic isProperty(String key) {
    return properties.containsKey(key);
  }

  dynamic getProperty(String key, dynamic defValue) {
    if (properties.containsKey(key)) {
      return properties[key];
    }
    setProperty(key, defValue);
    return defValue;
  }

  void setContext(String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    contextMap[key] = dynamicUIBuilderContext;
  }

  Map<String, dynamic> getContextMap() {
    Map<String, dynamic> result = {};
    for (MapEntry<String, DynamicUIBuilderContext> item in contextMap.entries) {
      result[item.key] = item.value.data;
    }
    return result;
  }

  void renderFloatingActionButton() {
    if (NavigatorApp.getLast() == this) {
      bool hide = true;
      if (contextMap.containsKey("root") && contextMap["root"]!.data.containsKey("template")) {
        if (contextMap["root"]!.data["template"]!.containsKey("floatingActionButton")) {
          DynamicInvoke().sysInvokeType(
            ShowHandler,
            {
              "case": "actionButton",
              "template": contextMap["root"]!.data["template"]["floatingActionButton"],
            },
            dynamicUIBuilderContext,
          );
        } else if (contextMap["root"]!.data["template"]!.containsKey("onRenderFloatingActionButton")) {
          AbstractWidget.clickStatic(
            contextMap["root"]!.data["template"],
            dynamicUIBuilderContext,
            "onRenderFloatingActionButton",
          );
        }
      }
      if (hide) {
        DynamicInvoke().sysInvokeType(HideHandler, {"case": "actionButton"}, dynamicUIBuilderContext);
      }
    }
  }

  @override
  State<DynamicPage> createState() => _DynamicPage();

  void updateNotifier(String uuid, Map<String, dynamic> data) {
    storeValueNotifier.updateValueNotifier(uuid, data);
    // shadowUuidList содержит uuid отображённых данных без NotifyWidget
    // Например в ChildrenExtension
    if (shadowUuidList.contains(uuid)) {
      print("TODO: Что то в этом блоке не так, пока видиться рекурсия на setSateData");
      //DataSource().setData(stateData);
    }
    if (listUpdateUuidToReloadDynamicPage.contains(uuid)) {
      reloadWithoutSetState();
    }
  }

  String templateByMapContext(Map<String, dynamic> data, List<String> parseArguments) {
    String uuid = parseArguments[0];
    String selector = parseArguments[1];
    dynamic defValue = parseArguments.length == 3 ? parseArguments[2] : null;

    if (uuid == "this") {
      return Template.stringSelector(data, selector, defValue);
    } else if (contextMap.containsKey(uuid)) {
      return Template.stringSelector(contextMap[uuid]!.data, selector, defValue);
    } else {
      return "DynamicPage.template() args: ${parseArguments.join(",")} context not exists";
    }
  }

  void addShadowUuid(String? uuid) {
    if (uuid == null) {
      return;
    }
    if (!shadowUuidList.contains(uuid)) {
      shadowUuidList.add(uuid);
    }
  }

  void removeShadowUuid(String uuid) {
    shadowUuidList.remove(uuid);
  }
}

class _DynamicPage extends State<DynamicPage> {
  @override
  void initState() {
    widget.dynamicPageSate = this;
    NavigatorApp.addPage(widget);
    super.initState();
  }

  @override
  void dispose() {
    NavigatorApp.removePage(widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    widget.constructor();
    dynamic resultWidget = DynamicUI.render(widget.arguments, null, const SizedBox(), widget.dynamicUIBuilderContext);
    if (resultWidget == null || resultWidget.runtimeType.toString().contains("Map<String,")) {
      return Text("DynamicPage.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
    }
    return resultWidget;
  }
}

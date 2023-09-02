import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/audio_component.dart';
import 'package:rjdu/dynamic_invoke/handler/hide_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/show_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/subscribe_reload.dart';
import 'package:rjdu/subscribe_reload_group.dart';
import 'package:rjdu/util/template.dart';
import 'package:rjdu/state_data.dart';
import 'package:rjdu/web_socket_service.dart';

import 'dynamic_invoke/dynamic_invoke.dart';
import 'store_value_notifier.dart';
import 'dynamic_ui/dynamic_ui.dart';
import 'navigator_app.dart';
import 'system_notify.dart';
import 'util.dart';
import 'db/data_source.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';

import 'dynamic_ui/widget/abstract_widget.dart';

class DynamicPage extends StatefulWidget {
  late final Map<String, dynamic> arguments;
  final Map<String, dynamic> properties = {};
  final StoreValueNotifier storeValueNotifier = StoreValueNotifier();
  final StateData stateData = StateData();
  late final DynamicUIBuilderContext dynamicUIBuilderContext;
  final Map<String, DynamicUIBuilderContext> contextMap = {};
  BuildContext? context;
  bool newRender = true;

  final String uuid = Util.uuid();
  bool isRunConstructor = false;

  final Map<SubscribeReloadGroup, List<String>> _subscribedOnReload = {
    SubscribeReloadGroup.uuid: [],
    SubscribeReloadGroup.parentUuid: [],
    SubscribeReloadGroup.key: [],
  };
  _DynamicPage? _setState;
  bool isDispose = false;
  int openInIndexTab = 0;

  void subscribeToReload(SubscribeReloadGroup group, String value) {
    if (kDebugMode) {
      print("DynamicPage.subscribeToReload(${group.name}) $value");
    }
    if (!_subscribedOnReload[group]!.contains(value)) {
      _subscribedOnReload[group]!.add(value);
    }
  }

  DynamicPage(parseJson, {super.key}) {
    arguments = Util.getMutableMap(parseJson);
    dynamicUIBuilderContext = DynamicUIBuilderContext(this, "root");
    dynamicUIBuilderContext.isRoot = true;
    //Инициализируем основной контейнер, так как js constructor начинает работать раньше чем будет возможноя отрисовка
    // Notify "onStateDataUpdate": true к примеру. Так было на Less.js, когда пытались поработать с main, который ещё
    // не успел инициализироваться
    stateData.getInstanceData(null);
    SystemNotify().subscribe(SystemNotifyEnum.changeOrientation, onChangeOrientation);
  }

  void constructor() {
    if (!isRunConstructor) {
      isRunConstructor = true;
      if (arguments.containsKey("constructor") && arguments["constructor"].isNotEmpty) {
        AbstractWidget.clickStatic(arguments, dynamicUIBuilderContext, "constructor");
      }
      if (arguments.containsKey("subscribeRefresh")) {
        DynamicInvoke().sysInvokeType(SubscribeReloadHandler, arguments["subscribeRefresh"], dynamicUIBuilderContext);
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

  void reload(bool rebuild) {
    if (rebuild) {
      properties.clear(); //Что бы стереть TextFieldController при перезагрузке страницы
      stateData.clear();
      AudioComponent().stop();
      isRunConstructor = false;
      if (_setState != null) {
        newRender = true;
        _setState!.setState(() {});
      }
    } else {
      // Это относится к лояльной перезагрузке, когда клиент мог что-то вводить в формы и тут пришло обновление
      isRunConstructor = false;
      // Все надежды на конструктор, что он перерисует необходимые блоки
      // В основном, это сводится к выборке из БД и обновления состояния
      constructor();
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

  void updateStoreValueNotifier(String uuid, Map<String, dynamic> data) {
    storeValueNotifier.updateValueNotifier(uuid, data);
    if (checkSubscribeReload(SubscribeReloadGroup.uuid, uuid)) {
      reload(false);
    }
  }

  bool checkSubscribeReload(SubscribeReloadGroup group, String value) {
    // Косвенные зависимости, установленные в обход Notify
    return _subscribedOnReload[group]!.contains(value);
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
}

class _DynamicPage extends State<DynamicPage> {
  @override
  void initState() {
    widget._setState = this;
    NavigatorApp.addPage(widget);
    super.initState();
  }

  @override
  void dispose() {
    NavigatorApp.removePage(widget);
    super.dispose();
  }

  dynamic resultWidget = const Text("DynamicUI");

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    if (widget.newRender) {
      widget.constructor();
      resultWidget = DynamicUI.render(widget.arguments, null, const SizedBox(), widget.dynamicUIBuilderContext);
      if (resultWidget == null || resultWidget.runtimeType.toString().contains("Map<String,")) {
        return Text("DynamicPage.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
      }
      widget.newRender = false;
    }
    return resultWidget;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rjdu/audio_component.dart';
import 'package:rjdu/dynamic_invoke/handler/hide_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/show_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/subscribe_reload.dart';
import 'package:rjdu/subscribe_reload_group.dart';
import 'package:rjdu/util/template.dart';
import 'package:rjdu/state_data.dart';
import 'package:rjdu/util/template/Parser/template_item.dart';
import 'package:rjdu/web_socket_service.dart';

import 'abstract_controller_wrap.dart';
import 'data_sync.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'dynamic_ui/type_parser.dart';
import 'store_value_notifier.dart';
import 'dynamic_ui/dynamic_ui.dart';
import 'navigator_app.dart';
import 'system_notify.dart';
import 'util.dart';
import 'db/data_source.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'db/data.dart';

import 'dynamic_ui/widget/abstract_widget.dart';

enum DynamicPageOpenType { window, dialog, bottomSheet }

class DynamicPage extends StatefulWidget {
  late final Map<String, dynamic> arguments;
  final Map<String, dynamic> properties = {};
  final StoreValueNotifier storeValueNotifier = StoreValueNotifier();
  final StateData stateData = StateData();
  late final DynamicUIBuilderContext dynamicUIBuilderContext;
  final Map<String, DynamicUIBuilderContext> contextMap = {};
  BuildContext? context;
  bool newRender = true;
  late final DynamicPageOpenType dynamicPageOpenType;
  Map<String, List<TemplateItem>> cacheTemplate = {};

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
  int timeCreate = 0;
  bool reloadOnActiveViewport = false;
  bool reloadBackground = false;

  void subscribeToReload(SubscribeReloadGroup group, String value) {
    if (!_subscribedOnReload[group]!.contains(value)) {
      Util.p("DynamicPage.subscribeToReload() uuidPage: $uuid; group: ${group.name}; value: $value");
      _subscribedOnReload[group]!.add(value);
    }
  }

  DynamicPage(Map<String, dynamic> parseJson, this.dynamicPageOpenType, {super.key}) {
    arguments = Util.getMutableMap(parseJson);
    dynamicUIBuilderContext = DynamicUIBuilderContext(this, "root");
    dynamicUIBuilderContext.isRoot = true;
    //Инициализируем основной контейнер, так как js constructor начинает работать раньше чем будет возможноя отрисовка
    // Notify "onStateDataUpdate": true к примеру. Так было на Less.js, когда пытались поработать с main, который ещё
    // не успел инициализироваться
    Data state = stateData.getInstanceData(null);
    SystemNotify().subscribe(SystemNotifyEnum.changeOrientation, onChangeOrientation);
    timeCreate = DateTime.now().millisecondsSinceEpoch;
    Util.p("CreateInstance DynamicPage uuidPage: $uuid; uuidState: ${state.uuid}; args: $arguments");
  }

  void constructor() {
    if (!isRunConstructor) {
      isRunConstructor = true;
      if (arguments.containsKey("constructor") && arguments["constructor"].isNotEmpty) {
        AbstractWidget.clickStatic(arguments, dynamicUIBuilderContext, "constructor");
      }
      if (arguments.containsKey("subscribeToRefresh")) {
        DynamicInvoke().sysInvokeType(SubscribeReloadHandler, arguments["subscribeToRefresh"], dynamicUIBuilderContext);
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
    SystemNotify().unsubscribe(SystemNotifyEnum.changeOrientation, onChangeOrientation);
    DataSource().unsubscribe(onChangeUuid);
  }

  void onEvent(String key, Map<String, dynamic> args) {
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
    if (reloadOnActiveViewport) {
      reloadOnActiveViewport = false;
      Future.delayed(const Duration(seconds: 1), () {
        // Пытаемся избежать markNeedsBuild
        reload(true);
      });
    }
  }

  void reload(bool rebuild, [bool isChangeTheme = false]) {
    if (isDispose == false) {
      // Темы наверное часто не будут менять, но если поменяют в runTime - перегрузим всё страницы, что бы
      // не мелькала старая тема на не активных страницах
      if (NavigatorApp.getLast() == this || isChangeTheme || reloadBackground) {
        //Если перезагружается страница, на которой мы сейчас находимся
        if (NavigatorApp.getLast() == this) {
          AudioComponent().stop();
        }
        Util.p("DynamicPage.reload($rebuild) uuidPage: $uuid; subscription: $_subscribedOnReload; $arguments");
        if (rebuild) {
          clearProperty(); //Что бы стереть TextFieldController при перезагрузке страницы
          stateData.clear();
          isRunConstructor = false;
          if (_setState != null) {
            newRender = true;
            try {
              _setState!.setState(() {});
            } catch (error, stackTrace) {
              Util.printStackTrace("setState", error, stackTrace);
            }
          }
        } else {
          // Это относится к лояльной перезагрузке, когда клиент мог что-то вводить в формы и тут пришло обновление
          isRunConstructor = false;
          // Все надежды на конструктор, что он перерисует необходимые блоки
          // В основном, это сводится к выборке из БД и обновления состояния
          constructor();
        }
      } else {
        Util.p(
            "DynamicPage.reload($rebuild) BACKGROUND uuidPage: $uuid; subscription: $_subscribedOnReload; $arguments");
        reloadOnActiveViewport = true;
      }
    }
  }

  void clearProperty() {
    for (MapEntry<String, dynamic> item in properties.entries) {
      if (item.value is AbstractControllerWrap) {
        (item.value as AbstractControllerWrap).dispose();
      }
    }
    properties.clear();
  }

  void setProperty(String key, dynamic value) {
    if (value != null) {
      properties[key] = value;
      for (Function(String nameController, AbstractControllerWrap abstractControllerWrap) fn
          in subscribeAddController) {
        if (value is AbstractControllerWrap) {
          fn(key, value);
        }
      }
    }
  }

  dynamic isProperty(String key) {
    return properties.containsKey(key);
  }

  T? getPropertyFn<T>(String key, T? Function() getDefault) {
    if (!properties.containsKey(key)) {
      dynamic newProp = getDefault();
      if (newProp != null) {
        setProperty(key, newProp);
      } else {
        return null;
      }
    }
    return properties[key];
  }

  T getProperty<T>(String key, T defValue) {
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
      if (arguments.containsKey("floatingActionButton")) {
        DynamicInvoke().sysInvokeType(
          ShowHandler,
          {
            "case": "actionButton",
            "template": arguments["floatingActionButton"],
          },
          dynamicUIBuilderContext,
        );
        hide = false;
      } else if (arguments.containsKey("onRenderFloatingActionButton")) {
        AbstractWidget.clickStatic(
          arguments,
          dynamicUIBuilderContext,
          "onRenderFloatingActionButton",
        );
        hide = false;
      }
      if (hide) {
        DynamicInvoke().sysInvokeType(HideHandler, {"case": "actionButton"}, dynamicUIBuilderContext);
      }
    }
  }

  @override
  State<DynamicPage> createState() => _DynamicPage();

  void _updateStoreValueNotifierNative(String uuid, Map<String, dynamic> data) {
    storeValueNotifier.updateValueNotifier(uuid, data);
    if (checkSubscriptionOnReload(SubscribeReloadGroup.uuid, uuid)) {
      reload(false);
    }
  }

  void updateStoreValueNotifier(String uuid, Map<String, dynamic> data) {
    int timeOffset = DateTime.now().millisecondsSinceEpoch - timeCreate;
    int timeAnimationOpenWindow = 200;
    if (timeOffset >= timeAnimationOpenWindow) {
      _updateStoreValueNotifierNative(uuid, data);
    } else {
      Future.delayed(Duration(milliseconds: timeAnimationOpenWindow - timeOffset), () {
        _updateStoreValueNotifierNative(uuid, data);
      });
    }
  }

  bool checkSubscriptionOnReload(SubscribeReloadGroup group, String value) {
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

  dynamic api(Map<String, dynamic> args) {
    String error = "";
    switch (args["api"] ?? "default") {
      case "startReloadEach":
        if (args.containsKey("eachReload") && _setState != null) {
          _setState!.startReloadEach(args["eachReload"] ?? 30);
        } else {
          error = "eachReload or _setState == null";
        }
        break;
      case "stopReloadEach":
        if (_setState != null) {
          _setState!.stopReloadEach();
        } else {
          error = "state is null";
        }
        break;
    }
    if (error.isNotEmpty) {
      Util.printCurrentStack("DynamicPage.api() Error: $error; args: $args;");
    }
    return null;
  }

  List<Function(String nameController, AbstractControllerWrap abstractControllerWrap)> subscribeAddController = [];

  void onAppendController(Function(String nameController, AbstractControllerWrap abstractControllerWrap) fn) {
    if (!subscribeAddController.contains(fn)) {
      subscribeAddController.add(fn);
    }
  }
}

class _DynamicPage extends State<DynamicPage> {
  Timer? timerReload;

  void startReloadEach(int second) {
    Util.p("DynamicPage.startReloadEach($second) uuidPage: ${widget.uuid}");
    stopReloadEach();
    timerReload = Timer.periodic(Duration(seconds: second), (timer) {
      widget.reload(true);
    });
  }

  void stopReloadEach() {
    try {
      if (timerReload != null) {
        timerReload!.cancel();
      }
    } catch (error, stackTrace) {
      Util.printStackTrace("DynamicPage.dispose()", error, stackTrace);
    }
  }

  @override
  void initState() {
    widget._setState = this;
    NavigatorApp.addPage(widget);
    if (widget.arguments.containsKey("reloadEach")) {
      int reloadEach = TypeParser.parseInt(widget.arguments["reloadEach"]!) ?? 30;
      startReloadEach(reloadEach);
    }
    super.initState();
  }

  @override
  void dispose() {
    stopReloadEach();
    // Мы тут делаем дополниетльное удалние, если страница закрывается нативными срествами
    // В api мы это делаем сразу же, что бы данные в NavigatorApp были актуальны
    NavigatorApp.removePage(widget);
    super.dispose();
  }

  dynamic resultWidget = const Text("DynamicUI");

  @override
  Widget build(BuildContext context) {
    if (widget.arguments.containsKey("lazySync")) {
      DataSync().sync(Util.castListDynamicToString(widget.arguments["lazySync"])).then((value) {
        if (value > 0) {
          widget.reload(true);
        }
      });
    }
    if (widget.arguments.containsKey("reloadBackground")) {
      widget.reloadBackground = true;
    }
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

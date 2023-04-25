import 'package:flutter/material.dart';
import 'data_type.dart';
import 'db/data.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'dynamic_page_notifier.dart';
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
  final DynamicPageNotifier dynamicPageNotifier = DynamicPageNotifier();
  late final DynamicUIBuilderContext dynamicUIBuilderContext;
  final Map<String, DynamicUIBuilderContext> container = {};
  BuildContext? context;
  late final Data stateData;
  final String uuid = const Uuid().v4();
  bool isRunConstructor = false;
  List<String> shadowUuidList = [];
  Map<String, dynamic> constructorArguments = {};

  DynamicPage(parseJson, {super.key}) {
    arguments = Util.getMutableMap(parseJson);
    stateData = Data(uuid, {}, DataType.virtual, null);
    dynamicUIBuilderContext = DynamicUIBuilderContext(this);
  }

  void constructor(Map<String, dynamic> parsedJson) {
    if (!isRunConstructor) {
      isRunConstructor = true;
      constructorArguments = parsedJson;
      if (constructorArguments.isNotEmpty) {
        AbstractWidget.clickStatic(
            constructorArguments, dynamicUIBuilderContext, "constructor");
      }
    }
  }

  void reload() {
    isRunConstructor = false;
    if (dynamicPageSate != null) {
      dynamicPageSate!.setState(() {});
    } else {
      constructor(constructorArguments);
    }
  }

  void setStateDataMap(Map<String, dynamic> map) {
    bool change = false;
    for (MapEntry<String, dynamic> item in map.entries) {
      if (stateData.value[item.key] != item.value) {
        stateData.value[item.key] = item.value;
        change = true;
      }
    }
    if (change) {
      DataSource().setData(stateData);
    }
  }

  void setStateData(String key, dynamic value) {
    if (stateData.value[key] != value) {
      stateData.value[key] = value;
      //print("setStateData [YES] key: $key; value: $value; pageUuid: $uuid; => ${stateData.value}");
      DataSource().setData(stateData);
    }
  }

  void setProperty(String key, dynamic value) {
    properties[key] = value;
  }

  dynamic getProperty(String key, dynamic defValue) {
    if (properties.containsKey(key)) {
      return properties[key];
    }
    setProperty(key, defValue);
    return defValue;
  }

  void setContainer(
      String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    container[key] = dynamicUIBuilderContext;
    if (key == "root") {
      dynamicUIBuilderContext.isRoot = true;
    }
  }

  Map<String, dynamic> getContainerData() {
    Map<String, dynamic> result = {};
    for (MapEntry<String, DynamicUIBuilderContext> item in container.entries) {
      result[item.key] = item.value.data;
    }
    return result;
  }

  void renderFloatingActionButton() {
    if (NavigatorApp.getLast() == this) {
      if (container.containsKey("root") &&
          container["root"]!.data.containsKey("template") &&
          container["root"]!
              .data["template"]!
              .containsKey("floatingActionButton")) {
        DynamicInvoke().sysInvoke(
          "DataSourceSet",
          {
            "uuid": "FloatingActionButton.json",
            "type": "virtual",
            "value": container['root']!.data["template"]["floatingActionButton"]
          },
          dynamicUIBuilderContext,
        );
      } else {
        DynamicInvoke().sysInvoke(
          "DataSourceSet",
          {
            "uuid": "FloatingActionButton.json",
            "type": "virtual",
            "value": Util.getMutableMap({}),
          },
          dynamicUIBuilderContext,
        );
      }
    }
  }

  _DynamicPage? dynamicPageSate;

  @override
  State<DynamicPage> createState() => _DynamicPage();

  void updateNotifier(String uuid, Map<String, dynamic> data) {
    //print("DynamicPage.updateNotifier() pageUuid: ${this.uuid}; updUuid: $uuid; arg: ${arguments["link"]}; data: $data");
    dynamicPageNotifier.updateNotifier(uuid, data);
    // listenUuid содержит uuid отображённых данных без NotifyWidget
    // Например в ChildrenExtension
    if (shadowUuidList.contains(uuid)) {
      DataSource().setData(stateData);
    }
  }

  String templateByContainer(List<String> parseArguments) {
    if (parseArguments.length == 2) {
      String uuid = parseArguments[0];
      if (container.containsKey(uuid)) {
        return Util.path2(container[uuid]!.data, parseArguments[1]);
      }
    }
    return "DynamicPage.template() args: ${parseArguments.join(",")} container not exists";
  }

  void addShadowUuid(String uuid) {
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
    SystemNotify().emit(SystemNotifyEnum.changeTabOrHistoryPop, "HistoryPop");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.context = context;
    dynamic resultWidget = DynamicUI.render(widget.arguments, null,
        const SizedBox(), widget.dynamicUIBuilderContext);
    if (resultWidget == null ||
        resultWidget.runtimeType.toString().contains('Map<String,')) {
      return Text(
          "DynamicPage.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
    }
    return resultWidget;
  }
}

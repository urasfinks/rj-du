import 'package:flutter/cupertino.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';

import 'db/data_source.dart';
import 'notify_object.dart';

/*
  * Задачи:
  * 1) Нам надо, что бы запрошенные на DynamicPage нотификаторы возвращались одни и тежи объекты, потому что page может перестраиваться
  * 2) Надо, что бы общие обновления данных вызывал update на всех DynamicPage
  * */

class DynamicPageNotifier {
  Map<String, ValueNotifier<NotifierObject>> mapNotifier = {};

  bool updateNotifier(String uuid, Map<String, dynamic> data) {
    bool isNotify = false;
    for (MapEntry<String, ValueNotifier<NotifierObject>> item in mapNotifier.entries) {
      NotifierObject notifierObject = item.value.value;
      if (notifierObject.link.values.toList().contains(uuid)) {
        notifierObject.set(uuid, data);
        item.value.notifyListeners();
        isNotify = true;
      }
    }
    return isNotify;
  }

  ValueListenableBuilder notifyWidget(
    Map<String, dynamic> link,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    Widget Function(BuildContext context, Widget? child) builder,
  ) {
    return ValueListenableBuilder<NotifierObject>(
      valueListenable: getNotifier(link),
      builder: (BuildContext context, NotifierObject value, Widget? child) {
        if (value.data.isNotEmpty) {
          for (MapEntry<String, dynamic> item in value.data.entries) {
            dynamicUIBuilderContext.data[item.key] = item.value;
          }
          dynamicUIBuilderContext.updateComplete();
        }
        dynamic resultWidget = builder(context, child);
        if (resultWidget == null || resultWidget.runtimeType.toString().contains('Map<String,')) {
          return Text("DynamicPageNotifier.builder() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
        }
        return resultWidget;
      },
    );
  }

  ValueNotifier<NotifierObject> getNotifier(Map<String, dynamic> link) {
    List<String> uuids = [];
    for (MapEntry<String, dynamic> item in link.entries) {
      uuids.add(item.value);
    }
    uuids.sort();
    String complexKey = uuids.join(",");
    if (!mapNotifier.containsKey(complexKey)) {
      NotifierObject notifierObject = NotifierObject(link);
      ValueNotifier<NotifierObject> valueNotifier = ValueNotifier<NotifierObject>(notifierObject);
      for (MapEntry<String, dynamic> item in link.entries) {
        DataSource().get(item.value, (uuid, data) {
          if (data != null && data.isNotEmpty) {
            notifierObject.set(item.value, data);
            valueNotifier.notifyListeners();
          }
        });
      }
      mapNotifier[complexKey] = valueNotifier;
    }
    return mapNotifier[complexKey]!;
  }
}

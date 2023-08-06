import 'package:flutter/cupertino.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';

import 'db/data_source.dart';
import 'notify_object.dart';

/*
  * Задачи:
  * 1) Нам надо, что бы запрошенные на DynamicPage нотификаторы возвращались одни и тежи объекты, потому что page может перестраиваться
  * 2) Надо, что бы общие обновления данных вызывал update на всех DynamicPage
  * */

class StoreValueNotifier {
  Map<String, ValueNotifier<SubscriberObject>> mapValueNotifier = {};

  bool updateValueNotifier(String uuid, Map<String, dynamic> data) {
    bool isNotify = false;
    for (MapEntry<String, ValueNotifier<SubscriberObject>> item in mapValueNotifier.entries) {
      SubscriberObject subscriberObject = item.value.value;
      if (subscriberObject.link.values.toList().contains(uuid)) {
        subscriberObject.set(uuid, data);
        item.value.notifyListeners();
        isNotify = true;
      }
    }
    return isNotify;
  }

  ValueListenableBuilder getWidget(
    Map<String, dynamic> link,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    Widget Function(BuildContext context, Widget? child) builder,
  ) {
    return ValueListenableBuilder<SubscriberObject>(
      valueListenable: getValueNotifier(link),
      builder: (BuildContext context, SubscriberObject value, Widget? child) {
        if (value.data.isNotEmpty) {
          List<String> updKeys = [];
          for (MapEntry<String, dynamic> item in value.data.entries) {
            dynamicUIBuilderContext.data[item.key] = item.value;
            updKeys.add(item.key);
          }
          dynamicUIBuilderContext.contextUpdate(updKeys);
        }
        dynamic resultWidget = builder(context, child);
        if (resultWidget == null || resultWidget.runtimeType.toString().contains('Map<String,')) {
          return Text("DynamicPageNotifier.builder() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
        }
        return resultWidget;
      },
    );
  }

  ValueNotifier<SubscriberObject> getValueNotifier(Map<String, dynamic> link) {
    List<String> uuids = [];
    for (MapEntry<String, dynamic> item in link.entries) {
      uuids.add(item.value);
    }
    uuids.sort();
    String complexKey = uuids.join(",");
    if (!mapValueNotifier.containsKey(complexKey)) {
      SubscriberObject subscriberObject = SubscriberObject(link);
      ValueNotifier<SubscriberObject> valueNotifier = ValueNotifier<SubscriberObject>(subscriberObject);
      for (MapEntry<String, dynamic> item in link.entries) {
        DataSource().get(item.value, (uuid, data) {
          if (data != null && data.isNotEmpty) {
            subscriberObject.set(item.value, data);
            valueNotifier.notifyListeners();
          }
        });
      }
      mapValueNotifier[complexKey] = valueNotifier;
    }
    return mapValueNotifier[complexKey]!;
  }
}

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
      ValueNotifier valueNotifier = item.value;
      SubscriberObject subscriberObject = valueNotifier.value;
      if (subscriberObject.link.values.toList().contains(uuid)) {
        subscriberObject.set(uuid, data);
        valueNotifier.notifyListeners();
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
      builder: (BuildContext context, SubscriberObject subscriberObject, Widget? child) {
        if (subscriberObject.data.isNotEmpty) {
          List<String> updateUuidList = [];
          List<String> updateKeyList = [];
          for (MapEntry<String, dynamic> item in subscriberObject.data.entries) {
            dynamicUIBuilderContext.data[item.key] = item.value;
            updateUuidList.add(subscriberObject.link[item.key]); //link: {blabla: uuid}; data:{blabla: {...}}
            updateKeyList.add(item.key);
          }
          dynamicUIBuilderContext.contextUpdate(updateUuidList, updateKeyList);
        }
        dynamic resultWidget = builder(context, child);
        if (resultWidget == null || resultWidget.runtimeType.toString().contains("Map<String,")) {
          return Text(
              "DynamicPageNotifier.builder() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
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
      // Первичное заполнение контейнеров
      for (MapEntry<String, dynamic> item in link.entries) {
        DataSource().get(item.value, (uuid, data) {
          if (data != null) {
            //&& data.isNotEmpty //убрал так как {} вызывает спорную ситуацию
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

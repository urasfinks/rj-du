import 'package:rjdu/util.dart';
import '../dynamic_page.dart';

class DynamicUIBuilderContext {
  final DynamicPage dynamicPage;
  int? index;
  String? key;
  Map<String, dynamic> data = {};
  bool isRoot = false; //Корневой контекст данных
  List<DynamicUIBuilderContext> cloned = [];
  Map<String, dynamic> linkedNotify = {}; //Прилинкованные Данные

  void onContextUpdate(List<String> updateUuidList, List<String> updateKeyList) {
    if (isRoot) {
      dynamicPage.renderFloatingActionButton();
    }
    // Так как состояние представлено в виде виртуальных данных
    // Которые по стандартной схеме NotifyWidget перерисовывают UI
    // По факту это отдельная структура от context
    // Поэтому для неё будем вызывать отдельный обработчик
    // Был кейс, когда я ждал данные из БД и в момент их получения устанавливал новое состоние в итоге получалась рекурсия

    List<String> contextUpdateList = [];
    List<String> stateUpdateList = [];
    for (String updateUuid in updateUuidList) {
      if (dynamicPage.stateData.isStateUuid(updateUuid)) {
        stateUpdateList.add(updateUuid);
      } else {
        contextUpdateList.add(updateUuid);
      }
    }
    if (contextUpdateList.isNotEmpty) {
      dynamicPage.onEvent("onContextUpdate", {
        "contextKey": key,
        "updateUuidList": contextUpdateList,
        "updateKeyList": updateKeyList,
      });
    }
    if (stateUpdateList.isNotEmpty) {
      dynamicPage.onEvent("onStateUpdate", {
        "contextKey": key,
        "updateUuidList": stateUpdateList,
        "updateKeyList": updateKeyList,
      });
    }
  }

  DynamicUIBuilderContext(this.dynamicPage, this.key) {
    if (key != null) {
      dynamicPage.setContext(key!, this);
    }
  }

  static String template(List<String> args) {
    return "";
  }

  // DynamicUIBuilderContext clone(String key) {
  //   DynamicUIBuilderContext newDynamicUIBuilderContext = DynamicUIBuilderContext(dynamicPage, key);
  //   children.add(newDynamicUIBuilderContext);
  //   return newDynamicUIBuilderContext;
  // }

  DynamicUIBuilderContext cloneWithNewData(Map<String, dynamic> newData, String? key) {
    DynamicUIBuilderContext newDynamicUIBuilderContext = DynamicUIBuilderContext(dynamicPage, key);
    newDynamicUIBuilderContext.data = newData;
    cloned.add(newDynamicUIBuilderContext);
    return newDynamicUIBuilderContext;
  }

  dynamic gets() {
    List ch = [];
    for (DynamicUIBuilderContext ctx in cloned) {
      ch.add(ctx.gets());
    }
    return {"root": isRoot, "key": key, "linkedNotify": linkedNotify, "data": data, "cloned": ch};
  }

  @override
  String toString() {
    return Util.jsonEncode(gets(), true);
  }
}

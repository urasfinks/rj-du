import 'package:rjdu/global_settings.dart';
import 'package:rjdu/util.dart';

import '../dynamic_page.dart';

class DynamicUIBuilderContext {
  final DynamicPage dynamicPage;
  int? index;
  String? key;
  Map<String, dynamic> data = {};
  Map<String, dynamic> parentTemplate = {}; //Времянка, только для шаблонизации (это очень не стабильная штука)
  bool isRoot = false; //Корневой контекст данных
  List<DynamicUIBuilderContext> children = [];
  List<String> listener = [];

  void addListener(String uuid) {
    if (GlobalSettings().debug) {
      if (!listener.contains(uuid)) {
        listener.add(uuid);
      }
    }
  }

  void contextUpdate(List<String> updKeys) {
    if (isRoot) {
      dynamicPage.renderFloatingActionButton();
    }
    // Так как состояние представлено в виде виртуальных данных
    // Которые по стандартной схеме NotifyWidget перерисовывают UI
    // По факту это отдельная структура от context
    // Поэтому для неё будем вызывать отдельный обработчик
    // Был кейс, когда я ждал данные из БД и в момент их получения устанавливал новое состоние в итоге получалась рекурсия
    dynamicPage
        .onEvent(updKeys.contains("stateData") ? "onStateUpdate" : "onContextUpdate", {"key": key, "updKeys": updKeys});
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
    children.add(newDynamicUIBuilderContext);
    return newDynamicUIBuilderContext;
  }

  dynamic gets() {
    List ch = [];
    for (DynamicUIBuilderContext ctx in children) {
      ch.add(ctx.gets());
    }
    return {"root": isRoot, "key": key, "listener": listener, "data": data, "children": ch};
  }

  @override
  String toString() {
    return Util.jsonEncode(gets(), true);
  }
}

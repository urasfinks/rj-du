import '../dynamic_page.dart';

class DynamicUIBuilderContext {
  final DynamicPage dynamicPage;
  int? index;
  String? key;
  Map<String, dynamic> data = {};
  Map<String, dynamic> parentTemplate = {}; //Времянка, только для шаблонизации (это очень не стабильная штука)
  bool isRoot = false; //Корневой контекст данных

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
        .onEvent(updKeys.contains("stateData") ? "stateUpdate" : "contextUpdate", {"data": data, "upd": updKeys});
  }

  DynamicUIBuilderContext(this.dynamicPage);

  static String template(List<String> args) {
    return "";
  }

  DynamicUIBuilderContext clone() {
    return DynamicUIBuilderContext(dynamicPage);
  }

  DynamicUIBuilderContext cloneWithNewData(Map<String, dynamic> newData) {
    DynamicUIBuilderContext dynamicUIBuilderContext = DynamicUIBuilderContext(dynamicPage);
    dynamicUIBuilderContext.data = newData;
    return dynamicUIBuilderContext;
  }
}

import '../dynamic_page.dart';

class DynamicUIBuilderContext {
  final DynamicPage dynamicPage;
  int? index;
  String? key;
  Map<String, dynamic> data = {};
  Map<String, dynamic> parentTemplate = {}; //Времянка, только для шаблонизации (это очень не стабильная штука)
  bool isRoot = false; //Корневой контекст данных

  void contextUpdate(List<String> upd) {
    if (isRoot) {
      dynamicPage.renderFloatingActionButton();
    }
    dynamicPage.onEvent("contextUpdate", {"data": data, "upd": upd});
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

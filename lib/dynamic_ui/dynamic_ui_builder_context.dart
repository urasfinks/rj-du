import '../dynamic_page.dart';

class DynamicUIBuilderContext {
  final DynamicPage dynamicPage;
  int? index;
  String? key;
  Map<String, dynamic> data = {};
  bool isRoot = false; //Корневой контекст данных

  void updateDataComplete() {
    if(isRoot){
      dynamicPage.renderFloatingActionButton();
    }
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

import '../../dynamic_ui_builder_context.dart';

class AbstractExtension {
  static void removeLastShadowUuid(
      String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List earlyUuids =
    dynamicUIBuilderContext.dynamicPage.getProperty(key, []) as List;
    for (String earlyUuid in earlyUuids) {
      dynamicUIBuilderContext.dynamicPage.removeShadowUuid(earlyUuid);
    }
  }
}

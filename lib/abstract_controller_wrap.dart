import 'dynamic_ui/dynamic_ui_builder_context.dart';

abstract class AbstractControllerWrap<T> {
  late T controller;

  AbstractControllerWrap(this.controller);

  T getController() {
    return controller;
  }

  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext);

  void dispose();
}

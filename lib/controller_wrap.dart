import 'dynamic_ui/dynamic_ui_builder_context.dart';

abstract class ControllerWrap<T> {
  late T controller;

  ControllerWrap(this.controller);

  T getController() {
    return controller;
  }

  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext);
}

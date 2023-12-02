import 'dynamic_ui/dynamic_ui_builder_context.dart';

abstract class AbstractControllerWrap<T> {
  T controller;
  Map<String, dynamic> stateControl;

  AbstractControllerWrap(this.controller, this.stateControl);

  T getController() {
    return controller;
  }

  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext);

  void dispose();
}

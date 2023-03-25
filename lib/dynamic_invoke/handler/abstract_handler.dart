import '../../dynamic_ui/dynamic_ui_builder_context.dart';

abstract class AbstractHandler{
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext);
}
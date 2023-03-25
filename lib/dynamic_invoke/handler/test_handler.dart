import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class TestHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    print("Hello world");
    return null;
  }
}

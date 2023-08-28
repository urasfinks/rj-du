import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class UuidHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    return {"uuid": Util.uuid()};
  }
}

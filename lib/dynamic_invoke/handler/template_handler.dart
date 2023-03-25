import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class TemplateHandler extends AbstractHandler {
  @override
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    for (MapEntry<String, dynamic> item in args.entries) {
      args[item.key] = Util.template(item.value, dynamicUIBuilderContext);
    }
    return args;
  }
}

import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/type_parser.dart';
import 'package:rjdu/subscribe_reload_group.dart';
import 'package:rjdu/util.dart';

class SubscribeReloadHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    add(args, dynamicUIBuilderContext, SubscribeReloadGroup.uuid.name);
    add(args, dynamicUIBuilderContext, SubscribeReloadGroup.parentUuid.name);
    add(args, dynamicUIBuilderContext, SubscribeReloadGroup.key.name);
  }

  void add(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext, String key) {
    String listKeyCapitalize = "list${Util.capitalize(key)}";
    SubscribeReloadGroup? subscribeReloadGroup = TypeParser.parseSubscribeReloadGroup(key);
    if (subscribeReloadGroup != null) {
      if (args.containsKey(key)) {
        dynamicUIBuilderContext.dynamicPage.subscribeToReload(subscribeReloadGroup, args[key]);
      } else if (args.containsKey(listKeyCapitalize)) {
        for (String item in args[listKeyCapitalize]) {
          dynamicUIBuilderContext.dynamicPage.subscribeToReload(subscribeReloadGroup, item);
        }
      }
    }
  }
}

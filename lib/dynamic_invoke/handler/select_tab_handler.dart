import '../../bottom_tab_item.dart';
import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../dynamic_ui/type_parser.dart';
import 'abstract_handler.dart';

class SelectTabHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    int? index;
    if (args.containsKey("index")) {
      index = TypeParser.parseInt(args["index"]);
    }
    if (args.containsKey("name")) {
      int count = 0;
      for (BottomTabItem bottomTabItem in NavigatorApp.tab) {
        if (bottomTabItem.name == args["name"]) {
          index = count;
          break;
        }
        count++;
      }
    }
    if (index != null) {
      NavigatorApp.bottomTabState?.selectTab(index);
    }
  }
}

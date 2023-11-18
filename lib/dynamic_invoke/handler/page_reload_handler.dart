import '../../data_sync.dart';
import '../../dynamic_ui/type_parser.dart';
import '../../navigator_app.dart';
import '../../subscribe_reload_group.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class PageReloadHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (!args.containsKey("case") || args["case"] == null) {
      args["case"] = "byArguments";
    }
    bool rebuild = args["rebuild"] ?? true;
    dynamic fnReload;
    switch (args["case"]) {
      case "all":
        NavigatorApp.reloadAllPages();
        break;
      case "byArguments":
        fnReload = () {
          Util.p("PageReloadHandler.fnReload(byArguments)");
          NavigatorApp.reloadPageByArguments(args["key"], args["value"], rebuild);
        };
        break;
      case "subscribed":
        fnReload = () {
          Map<SubscribeReloadGroup, List<String>> mapMultiUpdate = {
            SubscribeReloadGroup.key: [],
            SubscribeReloadGroup.parentUuid: [],
            SubscribeReloadGroup.uuid: [],
          };
          add(args, mapMultiUpdate, SubscribeReloadGroup.uuid.name);
          add(args, mapMultiUpdate, SubscribeReloadGroup.parentUuid.name);
          add(args, mapMultiUpdate, SubscribeReloadGroup.key.name);
          NavigatorApp.reloadPageBySubscription(mapMultiUpdate, args["rebuild"] ?? true);
        };
        break;
      case "current":
      default:
        fnReload = () {
          Util.p("PageReloadHandler.fnReload(current)");
          dynamicUIBuilderContext.dynamicPage.reload(rebuild);
        };
        Util.p("PageReloadHandler WTF?");
        break;
    }
    bool sync = args.containsKey("sync") && args["sync"] == true;
    if (sync) {
      Future<void> sync2 = DataSync().sync();
      sync2.then((_) {
        fnReload();
      }).onError((error, stackTrace) {
        Util.printStackTrace("PageReloadHandler.handle()", error, stackTrace);
      });
    } else {
      fnReload();
    }
  }

  void add(Map<String, dynamic> args, Map<SubscribeReloadGroup, List<String>> mapMultiUpdate, String key) {
    String listKeyCapitalize = "list${Util.capitalize(key)}";
    SubscribeReloadGroup? subscribeReloadGroup = TypeParser.parseSubscribeReloadGroup(key);
    if (subscribeReloadGroup != null) {
      if (args.containsKey(key)) {
        mapMultiUpdate[subscribeReloadGroup]!.add(args[key]);
      } else if (args.containsKey(listKeyCapitalize)) {
        for (String item in args[listKeyCapitalize]) {
          mapMultiUpdate[subscribeReloadGroup]!.add(item);
        }
      }
    }
  }
}

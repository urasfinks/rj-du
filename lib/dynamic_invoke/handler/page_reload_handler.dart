import '../../data_sync.dart';
import '../../navigator_app.dart';
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
      case "byArguments":
        fnReload = () {
          Util.p("PageReloadHandler.fnReload(byArguments)");
          NavigatorApp.reloadPageByArguments(args["key"], args["value"], rebuild);
        };
        break;
      case "current":
        fnReload = () {
          Util.p("PageReloadHandler.fnReload(current)");
          dynamicUIBuilderContext.dynamicPage.reload(rebuild);
        };
        break;
      default:
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
}

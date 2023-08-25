import 'package:flutter/foundation.dart';
import '../../data_sync.dart';
import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class PageReloadHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    // if (kDebugMode) {
    //   print("PageReloadHandler args: $args");
    // }
    /*dynamic args = {
      "case": ["byArguments", "current"], //default byArguments
      "sync": false,
    };*/
    if (!args.containsKey("case") || args["case"] == null) {
      args["case"] = "byArguments";
    }
    bool rebuild = args["rebuild"] ?? true;
    dynamic fnReload;
    switch (args["case"]) {
      case "byArguments":
        fnReload = () {
          if (kDebugMode) {
            print("PageReloadHandler.fnReload(byArguments)");
          }
          NavigatorApp.reloadPageByArguments(args["key"], args["value"], rebuild);
        };
        break;
      case "current":
        fnReload = () {
          if (kDebugMode) {
            print("PageReloadHandler.fnReload(current)");
          }
          dynamicUIBuilderContext.dynamicPage.reload(rebuild);
        };
        break;
      default:
        if (kDebugMode) {
          print("PageReloadHandler WTF?");
        }
        break;
    }
    bool sync = args.containsKey("sync") && args["sync"] == true;
    if (sync) {
      Future<void> sync2 = DataSync().sync();
      sync2.then((_) {
        fnReload();
      });
    } else {
      fnReload();
    }
  }
}

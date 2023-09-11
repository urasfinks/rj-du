import 'package:rjdu/data_sync.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/navigator_app.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import '../../web_socket_service.dart';
import 'abstract_handler.dart';

class SystemHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "reloadAllPage":
        NavigatorApp.reloadAllPages();
        break;
      case "webSocketConnect":
        WebSocketService().addListener(dynamicUIBuilderContext.dynamicPage);
        break;
      case "webSocketDisconnect":
        WebSocketService().removeListener(dynamicUIBuilderContext.dynamicPage);
        break;
      case "dataSync":
        if (args["onSync"] != null) {
          Future<void> sync2 = DataSync().sync();
          sync2.then((_) {
            AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onSync");
          }).onError((error, stackTrace) {
            Util.printStackTrace("DataSyncHandler.handler()", error, stackTrace);
          });
        } else {
          DataSync().sync();
        }
        break;
      default:
        Util.p("SystemHandler.handle() default case args: $args");
        break;
    }
  }
}

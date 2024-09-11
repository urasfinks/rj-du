import '../../db/data_source.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../db/data.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class DataSourceSetHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["uuid", "value"])) {
      Data data = Data(
        args["uuid"],
        args["value"],
        Util.dataTypeValueOf(args["type"]),
        args["parent"],
      );
      if (args.containsKey("debugTransaction")) {
        data.debugTransaction = args["debugTransaction"];
      }
      if (args.containsKey("beforeSync")) {
        data.beforeSync = args["beforeSync"];
      }
      if (args.containsKey("updateIfExist")) {
        data.updateIfExist = args["updateIfExist"];
      }
      if (args.containsKey("onUpdateOverlayJsonValue")) {
        data.onUpdateOverlayJsonValue = args["onUpdateOverlayJsonValue"];
      }
      if (args.containsKey("key")) {
        data.key = args["key"];
      }
      if (args.containsKey("meta")) {
        data.meta = args["meta"];
      }
      if (args.containsKey("notify")) {
        data.notify = args["notify"];
      }
      DataSource().setData(data).then((_) {
        if (args["onPersist"] != null) {
          AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onPersist");
        }
      });
    } else {
      Util.log("DataSourceSetHandler not contains Keys: [uuid, value] in args: $args", type: "error", stack: true);
    }
  }
}
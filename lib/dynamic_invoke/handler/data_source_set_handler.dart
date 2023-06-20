import 'package:flutter/foundation.dart';
import '../../db/data_source.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../db/data.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class DataSourceSetHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['uuid', 'value'])) {
      Data data = Data(
        args['uuid'],
        args['value'],
        Util.dataTypeValueOf(args['type']),
        args['parent'],
      );
      if (args.containsKey("debugTransaction")) {
        data.debugTransaction = args["debugTransaction"];
      }
      if (args.containsKey("addNewSocketData")) {
        data.beforeSync =
            true; //Немного обманем систему, что бы удалось в БД запихать данные с типо socket
      }
      data.key = args['key'];
      data.updateIfExist = true;
      if (args["onPersist"] != null) {
        data.onPersist = () {
          AbstractWidget.clickStatic(
              args, dynamicUIBuilderContext, "onPersist");
        };
      }
      DataSource().setData(data);
    } else {
      if (kDebugMode) {
        print(
            "DataSourceSetHandler not contains Keys: [uuid, value] in args: $args");
        print(StackTrace.current);
      }
    }
  }
}

import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../../data_sync.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';

class DataSyncHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args["onSync"] != null) {
      Future<void> sync2 = DataSync().sync();
      sync2.then((_) {
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onSync");
      });
    } else {
      DataSync().sync();
    }
  }
}

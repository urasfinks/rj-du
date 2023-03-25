import 'package:flutter_slidable/flutter_slidable.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class SlidableWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Slidable(
      key: Util.getKey(),
      endActionPane: ActionPane(
        extentRatio: TypeParser.parseDouble(
          getValue(parsedJson, 'extentRatio', 0.3, dynamicUIBuilderContext),
        )!,
        motion: const ScrollMotion(),
        children: renderList(parsedJson, 'children', dynamicUIBuilderContext),
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}

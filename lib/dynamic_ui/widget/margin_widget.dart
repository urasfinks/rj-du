import 'package:rjdu/dynamic_ui/widget/size_box_widget.dart';

import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter_margin_widget/flutter_margin_widget.dart';
import '../../util.dart';

class MarginWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Margin(
      key: Util.getKey(),
      margin: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'margin', null, dynamicUIBuilderContext),
      )!,
      child: render(
        parsedJson,
        'child',
        SizedBoxWidget().get(parsedJson, dynamicUIBuilderContext),
        dynamicUIBuilderContext,
      ),
    );
  }
}

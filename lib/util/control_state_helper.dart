import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';

import '../dynamic_ui/dynamic_ui_builder_context.dart';

enum ControlStateHelperEvent {
  onInitSetStateNotify(false), // Оповестить Notify при инициализации / переинициализации
  onChangedSetStateNotify(true), // Оповестить Notify при изменении состояния
  onChangeSetState(true), // Необходимость устанавливать состояние при изменении значения
  onInitSetState(true), // Необходимость устанавливать состояние при инициализации виджета
  onRebuildClearTemporaryControllerText(false); //Очищает временное состояние контроллера при rebuild

  final bool defValue;

  const ControlStateHelperEvent(this.defValue);
}

class ControlStateHelper {
  Map<ControlStateHelperEvent, bool> cur = {};
  final Map<String, dynamic> parsedJson;
  final DynamicUIBuilderContext dynamicUIBuilderContext;
  String keyState = "";
  String defaultData = "";

  ControlStateHelper(this.parsedJson, this.dynamicUIBuilderContext) {
    for (ControlStateHelperEvent item in ControlStateHelperEvent.values) {
      cur[item] = AbstractWidget.getValueStatic(parsedJson, item.name, item.defValue, dynamicUIBuilderContext);
    }

    keyState = AbstractWidget.getValueStatic(parsedJson, "name", "-", dynamicUIBuilderContext);
    defaultData = AbstractWidget.getValueStatic(parsedJson, "data", "", dynamicUIBuilderContext);

    //При первичной инициализации устанавливает значение в состояние
    if (!dynamicUIBuilderContext.dynamicPage.isProperty("init$keyState") &&
        cur[ControlStateHelperEvent.onInitSetState] == true) {
      dynamicUIBuilderContext.dynamicPage.stateData.set(
        parsedJson["state"],
        keyState,
        defaultData,
        cur[ControlStateHelperEvent.onInitSetStateNotify]!,
      );
      dynamicUIBuilderContext.dynamicPage.setProperty("init$keyState", "ANYTHING");
    }
  }

  bool isStatus(ControlStateHelperEvent controlStateHelperEvent) {
    return cur[controlStateHelperEvent]!;
  }

  init(ControlStateHelperEvent controlStateHelperEvent) {}

  onChange(dynamic value, [ControlStateHelperEvent isSet = ControlStateHelperEvent.onChangeSetState]) {
    if (cur[isSet]!) {
      dynamicUIBuilderContext.dynamicPage.stateData
          .set(parsedJson["state"], keyState, value, cur[ControlStateHelperEvent.onChangedSetStateNotify]!);
      AbstractWidget.clickStatic(parsedJson, dynamicUIBuilderContext, "onChanged");
    }
  }
}

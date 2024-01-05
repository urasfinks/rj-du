import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rjdu/util/control_state_helper.dart';
import '../../abstract_controller_wrap.dart';
import '../../dynamic_invoke/handler/alert_handler.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class TextFieldWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String type = getValue(parsedJson, "keyboardType", "text", dynamicUIBuilderContext);

    ControlStateHelper controlStateHelper = ControlStateHelper(parsedJson, dynamicUIBuilderContext);
    if (controlStateHelper.isStatus(ControlStateHelperEvent.onRebuildClearTemporaryControllerText)) {
      clearController(parsedJson, controlStateHelper.keyState, dynamicUIBuilderContext);
    }

    TextEditingController textController =
        getController(parsedJson, controlStateHelper.keyState, dynamicUIBuilderContext, () {
      return TextEditingControllerWrap(TextEditingController(text: controlStateHelper.defaultData), {});
    });

    if (textController.text.isNotEmpty) {
      textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
    }

    List<TextInputFormatter> listInputFormatters = [];
    String regExp = getValue(parsedJson, "regexp", "", dynamicUIBuilderContext);
    if (regExp.isNotEmpty) {
      listInputFormatters.add(FilteringTextInputFormatter.allow(RegExp("^[a-z0-9_-]{3,16}\$")));
    }

    bool hideKeyboardOnEditingComplete = TypeParser.parseBool(
      getValue(parsedJson, "hideKeyboardOnEditingComplete", true, dynamicUIBuilderContext),
    )!;

    return TextField(
      key: Util.getKey(),
      focusNode:
          dynamicUIBuilderContext.dynamicPage.getProperty("${controlStateHelper.keyState}_FocusNode", FocusNode()),
      onSubmitted: (value) {
        //В документации написано, что эта штука должна скрывать клавиатуру по умолчанию
        // if (parsedJson["hideKeyboardOnSubmitted"] ?? true == true) {
        //   FocusManager.instance.primaryFocus?.unfocus();
        // }
        controlStateHelper.onChange(value);
        click(parsedJson, dynamicUIBuilderContext, "onSubmitted");
      },
      //А наличие вот этой штуки не должно скрывать
      onEditingComplete: !hideKeyboardOnEditingComplete
          ? () {}
          : null,
      inputFormatters: listInputFormatters,
      textCapitalization: TypeParser.parseTextCapitalization(
        getValue(parsedJson, "textCapitalization", "sentences", dynamicUIBuilderContext),
      )!,
      minLines: TypeParser.parseInt(
        getValue(parsedJson, "minLines", 1, dynamicUIBuilderContext),
      ),
      maxLines: TypeParser.parseInt(
        getValue(parsedJson, "maxLines", null, dynamicUIBuilderContext),
      ),
      maxLength: TypeParser.parseInt(
        getValue(parsedJson, "maxLength", null, dynamicUIBuilderContext),
      ),
      textAlign: TypeParser.parseTextAlign(
        getValue(parsedJson, "textAlign", "start", dynamicUIBuilderContext),
      )!,
      textAlignVertical: TypeParser.parseTextAlignVertical(
        getValue(parsedJson, "textAlignVertical", null, dynamicUIBuilderContext),
      ),
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, "clipBehavior", "hardEdge", dynamicUIBuilderContext),
      )!,
      showCursor: TypeParser.parseBool(
        getValue(parsedJson, "showCursor", null, dynamicUIBuilderContext),
      ),
      autocorrect: TypeParser.parseBool(
        getValue(parsedJson, "autocorrect", true, dynamicUIBuilderContext),
      )!,
      autofocus: TypeParser.parseBool(
        getValue(parsedJson, "autofocus", false, dynamicUIBuilderContext),
      )!,
      expands: TypeParser.parseBool(
        getValue(parsedJson, "expands", false, dynamicUIBuilderContext),
      )!,
      enabled: TypeParser.parseBool(
        getValue(parsedJson, "enabled", null, dynamicUIBuilderContext),
      ),
      cursorColor: TypeParser.parseColor(
        getValue(parsedJson, "cursorColor", null, dynamicUIBuilderContext),
      ),
      readOnly: TypeParser.parseBool(
        getValue(parsedJson, "readOnly", (type == "datetime" || type == "time"), dynamicUIBuilderContext),
      )!,
      controller: textController,
      obscureText: TypeParser.parseBool(
        getValue(parsedJson, "obscureText", false, dynamicUIBuilderContext),
      )!,
      obscuringCharacter: getValue(parsedJson, "obscureText", "*", dynamicUIBuilderContext),
      keyboardType: TypeParser.parseTextInputType(type)!,
      decoration: render(parsedJson, "decoration", null, dynamicUIBuilderContext),
      style: render(parsedJson, "style", null, dynamicUIBuilderContext),
      onChanged: (value) {
        controlStateHelper.onChange(value);
      },
      onTap: () async {
        if (type == "datetime") {
          DateTime? pickedDate = await showDatePicker(
            locale: const Locale("ru", "ru_Ru"),
            context: dynamicUIBuilderContext.dynamicPage.context!,
            initialDate:
                textController.text.isNotEmpty ? DateFormat("dd.MM.yyyy").parse(textController.text) : DateTime.now(),
            firstDate: DateTime(1931),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            controlStateHelper.defaultData = DateFormat("dd.MM.yyyy").format(pickedDate);
            controlStateHelper.onChange(controlStateHelper.defaultData);
            textController.text = controlStateHelper.defaultData;
          } else {
            textController.text = "";
          }
        } else if (type == "time") {
          String currentText = textController.text;
          TimeOfDay tod = TimeOfDay.now();
          if (currentText.isNotEmpty) {
            List<String> exp = currentText.split(":");
            tod = TimeOfDay(hour: TypeParser.parseInt(exp[0])!, minute: TypeParser.parseInt(exp[1])!);
          }
          final TimeOfDay? result = await showTimePicker(
            builder: (context, child) {
              return Localizations.override(
                context: context,
                locale: const Locale("ru", "ru_Ru"),
                child: child,
              );
            },
            initialEntryMode: TimePickerEntryMode.input,
            initialTime: tod,
            context: dynamicUIBuilderContext.dynamicPage.context!,
          );
          if (result != null) {
            controlStateHelper.defaultData =
                "${Util.lPad(result.hour.toString(), pad: 2)}:${Util.lPad(result.minute.toString(), pad: 2)}";
            controlStateHelper.onChange(controlStateHelper.defaultData);
            textController.text = controlStateHelper.defaultData;
          }
        }
      },
    );
  }
}

class TextEditingControllerWrap extends AbstractControllerWrap<TextEditingController> {
  TextEditingControllerWrap(super.controller, super.stateControl);

  @override
  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String error = "";
    switch (args["case"] ?? "default") {
      case "reset":
        controller.text = args["text"] ?? "";
        //Сброс состояния контролера не должен перезагружать страницу
        //Перерисовка при включенном onRebuildClearTemporaryControllerText и setState перезапишет состояние
        //Цель зануления скорее всего, что бы записать новое значение, не держа backspace
        //А так мы просто получим перетерание на старое значение
        if (args["setState"] ?? true) {
          // controller = keyState
          if (args["controller"] != null) {
            dynamicUIBuilderContext.dynamicPage.stateData
                .set(args["state"], args["controller"], controller.text, args["notify"] ?? false);
          } else {
            error = "key is null";
          }
        }
        break;
      default:
        AlertHandler.alertSimple("TextEditingControllerWrap.invoke() args: $args");
        break;
    }
    if (error.isNotEmpty) {
      Util.printCurrentStack("TextEditingControllerWrap.invoke() Error $error; args: $args");
    }
  }

  @override
  void dispose() {
    controller.dispose();
  }
}

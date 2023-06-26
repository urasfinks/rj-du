import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class TextFieldWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = getValue(parsedJson, 'name', '-', dynamicUIBuilderContext);
    String defaultData = getValue(parsedJson, 'data', '', dynamicUIBuilderContext);

    String type = getValue(parsedJson, 'keyboardType', 'text', dynamicUIBuilderContext);

    bool rewriteState = parsedJson["rewriteState"] ?? false;

    TextEditingController textController =
        dynamicUIBuilderContext.dynamicPage.getProperty("${key}_TextEditingController", TextEditingController(text: defaultData));

    if (rewriteState == true) {
      dynamicUIBuilderContext.dynamicPage.setStateData(key, defaultData);
      textController.text = defaultData;
    }

    if (textController.text.isNotEmpty) {
      textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
    }

    List<TextInputFormatter> listInputFormatters = [];
    String regExp = getValue(parsedJson, 'regexp', '', dynamicUIBuilderContext);
    if (regExp.isNotEmpty) {
      listInputFormatters.add(FilteringTextInputFormatter.allow(RegExp('^[a-z0-9_-]{3,16}\$')));
    }

    bool onChangedNotify = TypeParser.parseBool(
      getValue(parsedJson, 'onChangedNotify', true, dynamicUIBuilderContext),
    )!;

    return TextField(
      key: Util.getKey(),
      focusNode: dynamicUIBuilderContext.dynamicPage.getProperty("${key}_FocusNode", FocusNode()),
      onSubmitted: (_) {
        click(parsedJson, dynamicUIBuilderContext, "onSubmitted");
      },
      onEditingComplete: () {
        click(parsedJson, dynamicUIBuilderContext, "onEditingComplete");
      },
      inputFormatters: listInputFormatters,
      textCapitalization: TypeParser.parseTextCapitalization(
        getValue(parsedJson, 'textCapitalization', 'sentences', dynamicUIBuilderContext),
      )!,
      minLines: TypeParser.parseInt(
        getValue(parsedJson, 'minLines', 1, dynamicUIBuilderContext),
      ),
      maxLines: TypeParser.parseInt(
        getValue(parsedJson, 'maxLines', null, dynamicUIBuilderContext),
      ),
      maxLength: TypeParser.parseInt(
        getValue(parsedJson, 'maxLength', null, dynamicUIBuilderContext),
      ),
      textAlign: TypeParser.parseTextAlign(
        getValue(parsedJson, 'textAlign', 'start', dynamicUIBuilderContext),
      )!,
      textAlignVertical: TypeParser.parseTextAlignVertical(
        getValue(parsedJson, 'textAlignVertical', null, dynamicUIBuilderContext),
      ),
      clipBehavior: TypeParser.parseClip(
        getValue(parsedJson, 'clipBehavior', 'hardEdge', dynamicUIBuilderContext),
      )!,
      showCursor: TypeParser.parseBool(
        getValue(parsedJson, 'showCursor', null, dynamicUIBuilderContext),
      ),
      autocorrect: TypeParser.parseBool(
        getValue(parsedJson, 'autocorrect', true, dynamicUIBuilderContext),
      )!,
      autofocus: TypeParser.parseBool(
        getValue(parsedJson, 'autofocus', false, dynamicUIBuilderContext),
      )!,
      expands: TypeParser.parseBool(
        getValue(parsedJson, 'expands', false, dynamicUIBuilderContext),
      )!,
      enabled: TypeParser.parseBool(
        getValue(parsedJson, 'enabled', null, dynamicUIBuilderContext),
      ),
      cursorColor: TypeParser.parseColor(
        getValue(parsedJson, 'cursorColor', null, dynamicUIBuilderContext),
      ),
      readOnly: TypeParser.parseBool(
        getValue(parsedJson, 'readOnly', (type == "datetime" || type == "time"), dynamicUIBuilderContext),
      )!,
      controller: textController,
      obscureText: TypeParser.parseBool(
        getValue(parsedJson, 'obscureText', false, dynamicUIBuilderContext),
      )!,
      obscuringCharacter: getValue(parsedJson, 'obscureText', '*', dynamicUIBuilderContext),
      keyboardType: TypeParser.parseTextInputType(type)!,
      decoration: render(parsedJson, 'decoration', null, dynamicUIBuilderContext),
      style: render(parsedJson, 'style', null, dynamicUIBuilderContext),
      onChanged: (value) {
        dynamicUIBuilderContext.dynamicPage.setStateData(key, value, onChangedNotify);
        click(parsedJson, dynamicUIBuilderContext, "onChanged");
      },
      onTap: () async {
        if (type == "datetime") {
          DateTime? pickedDate = await showDatePicker(
            locale: const Locale('ru', 'ru_Ru'),
            context: dynamicUIBuilderContext.dynamicPage.context!,
            initialDate: textController.text.isNotEmpty ? DateFormat("dd.MM.yyyy").parse(textController.text) : DateTime.now(),
            firstDate: DateTime(1931),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            defaultData = DateFormat('dd.MM.yyyy').format(pickedDate);
            dynamicUIBuilderContext.dynamicPage.setStateData(key, defaultData);
            textController.text = defaultData;
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
                locale: const Locale('ru', 'ru_Ru'),
                child: child,
              );
            },
            initialEntryMode: TimePickerEntryMode.input,
            initialTime: tod,
            context: dynamicUIBuilderContext.dynamicPage.context!,
          );
          if (result != null) {
            defaultData = "${Util.intLPad(result.hour, pad: 2)}:${Util.intLPad(result.minute, pad: 2)}";
            dynamicUIBuilderContext.dynamicPage.setStateData(key, defaultData);
            textController.text = defaultData;
          }
        }
      },
    );
  }
}

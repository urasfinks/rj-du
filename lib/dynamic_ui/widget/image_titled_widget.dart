import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../type_parser.dart';

class ImageTitledWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    double radius = TypeParser.parseDouble(
      getValue(parsedJson, "radius", 8.0, dynamicUIBuilderContext),
    )!;
    String label = getValue(parsedJson, "label", "", dynamicUIBuilderContext).toString();
    double fontSize = TypeParser.parseDouble(
      getValue(parsedJson, "fontSize", 15, dynamicUIBuilderContext),
    )!;
    dynamic childElement = const SizedBox();
    // Условия получились конечно не очень привычные и не очень красивые
    // Я испытывал проблемы с динамическим шаблоном, когда extra всегда заполнено из контекста
    // Можно лишь управлять содержимым extra вот так и пришлось выкручиваться
    parsedJson["childKey"] = getValue(parsedJson, "childKey", "", dynamicUIBuilderContext);
    if (parsedJson.containsKey("childKey") && parsedJson["childKey"].toString() != "") {
      childElement = render(parsedJson, parsedJson["childKey"], const SizedBox(), dynamicUIBuilderContext);
    }
    parsedJson["onTap"] = getValue(parsedJson, "onTap", "", dynamicUIBuilderContext);
    if (parsedJson.containsKey("onTap") && parsedJson["onTap"].toString() != "") {
      childElement = Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              click(parsedJson, dynamicUIBuilderContext, "onTap");
            },
            child: childElement,
          ),
        ),
      );
    } else {
      childElement = Positioned.fill(
        child: childElement,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Stack(
        children: <Widget>[
          render(parsedJson, "image", const SizedBox(), dynamicUIBuilderContext),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                  stops: [0.45, 1],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: TypeParser.parseEdgeInsets(
                getValue(parsedJson, "padding", "10,10,10,5", dynamicUIBuilderContext),
              )!,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          childElement
        ],
      ),
    );
  }
}

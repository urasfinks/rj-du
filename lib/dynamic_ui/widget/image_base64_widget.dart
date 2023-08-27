import 'package:rjdu/dynamic_invoke/handler/subscribe_reload.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../util.dart';
import '../type_parser.dart';

class ImageBase64Widget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return dynamicUIBuilderContext.dynamicPage.storeValueNotifier.getWidget(
      {"src": parsedJson["src"]},
      dynamicUIBuilderContext,
      (context, child) {
        if (dynamicUIBuilderContext.data.containsKey("src")) {
          String x = dynamicUIBuilderContext.data["src"]["blobRSync"];
          //TODO: можно загрузить в состояния страницы, что бы повторная перерисовка была без assetLoader
          DynamicInvoke().sysInvokeType(SubscribeReloadHandler, {"uuid": parsedJson["src"]}, dynamicUIBuilderContext);
          return getMemory(x, parsedJson, dynamicUIBuilderContext);
        } else {
          return getAsset(parsedJson, dynamicUIBuilderContext);
        }
      },
    );
  }

  getAsset(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (parsedJson.containsKey("assetLoader")) {
      return Image(
        image: AssetImage(parsedJson["assetLoader"]!),
      );
    } else {
      return const SizedBox();
    }
  }

  getMemory(String imageData, Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Image.memory(
      Util.base64Decode(imageData),
      key: Util.getKey(),
      width: TypeParser.parseDouble(
        getValue(parsedJson, "width", null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        getValue(parsedJson, "height", null, dynamicUIBuilderContext),
      ),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, "fit", null, dynamicUIBuilderContext),
      ),
      scale: TypeParser.parseDouble(
        getValue(parsedJson, "scale", 1.0, dynamicUIBuilderContext),
      )!,
      repeat: TypeParser.parseImageRepeat(
        getValue(parsedJson, "repeat", "noRepeat", dynamicUIBuilderContext),
      )!,
      filterQuality: FilterQuality.high,
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, "alignment", "center", dynamicUIBuilderContext),
      )!,
    );
  }
}

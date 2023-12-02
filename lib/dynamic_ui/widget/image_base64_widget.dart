import 'package:rjdu/data_type.dart';
import 'package:rjdu/db/data_source.dart';
import 'package:rjdu/dynamic_invoke/handler/subscribe_reload.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';

import '../../abstract_stream.dart';
import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../util.dart';
import '../type_parser.dart';

class ImageBase64Widget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    AbstractStream abstractStream = getController(parsedJson, "ImageBase64Widget", dynamicUIBuilderContext, () {
      StreamData streamData = StreamData({"image": null, "start": false});
      return StreamControllerWrap(streamData, streamData.data);
    });
    if (abstractStream.getData()["start"] == false) {
      abstractStream.getData()["start"] = true;
      String src = getValue(parsedJson, "src", "", dynamicUIBuilderContext);
      DataSource().get(src, (uuid, data) {
        for (String key in [DataType.blobRSync.name, DataType.blob.name]) {
          if (data != null && data.containsKey(key)) {
            abstractStream.setData({
              "image": data[key],
            });
            break;
          }
        }
      });
    }
    DynamicInvoke().sysInvokeType(SubscribeReloadHandler, {"uuid": parsedJson["src"]}, dynamicUIBuilderContext);
    return StreamWidget.getWidget(abstractStream, (snapshot) {
      if (snapshot["image"] == null) {
        return getAsset(parsedJson, dynamicUIBuilderContext);
      } else {
        return getMemory(snapshot["image"], parsedJson, dynamicUIBuilderContext);
      }
    });
  }

  getAsset(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (parsedJson.containsKey("assetLoader")) {
      return Image(
        key: Util.getKey(),
        image: AssetImage(parsedJson["assetLoader"]!),
        width: TypeParser.parseDouble(
          getValue(parsedJson, "width", null, dynamicUIBuilderContext),
        ),
        height: TypeParser.parseDouble(
          getValue(parsedJson, "height", null, dynamicUIBuilderContext),
        ),
        fit: TypeParser.parseBoxFit(
          getValue(parsedJson, "fit", null, dynamicUIBuilderContext),
        ),
        repeat: TypeParser.parseImageRepeat(
          getValue(parsedJson, "repeat", "noRepeat", dynamicUIBuilderContext),
        )!,
        filterQuality: FilterQuality.high,
        alignment: TypeParser.parseAlignment(
          getValue(parsedJson, "alignment", "center", dynamicUIBuilderContext),
        )!,
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

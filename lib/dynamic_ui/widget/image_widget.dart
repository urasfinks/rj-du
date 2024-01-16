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

class ImageWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, "src", "", dynamicUIBuilderContext);
    AbstractStream abstractStream = getController(parsedJson, "ImageWidget", dynamicUIBuilderContext, () {
      StreamData streamData = StreamData({"image": null, "start": false, "src": src, "startOpacity": 0.0});
      return StreamControllerWrap(streamData, streamData.data);
    });
    if (abstractStream.getData()["start"] == false) {
      abstractStream.getData()["start"] = true;
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
      DynamicInvoke().sysInvokeType(SubscribeReloadHandler, {"uuid": src}, dynamicUIBuilderContext);
    }
    Key keyWidget = Util.getKey();
    Key keyAnimation = Util.getKey();
    return StreamWidget.getWidget(abstractStream, (snapshot) {
      dynamic imageWidget = const SizedBox();
      if (snapshot["image"] != null) {
        imageWidget = getMemory(snapshot["image"], parsedJson, dynamicUIBuilderContext, keyWidget);
      } else if (parsedJson.containsKey("assetLoader")) {
        imageWidget = getAsset(parsedJson, dynamicUIBuilderContext, keyWidget);
      }
      if (parsedJson.containsKey("animation") && parsedJson["animation"] == true) {
        return TweenAnimationBuilder<double>(
            key: keyAnimation,
            tween: Tween<double>(begin: abstractStream.getData()["startOpacity"], end: 1.0),
            curve: Curves.ease,
            duration: Duration(milliseconds: parsedJson["animationDuration"] ?? 250),
            builder: (BuildContext context, double opacity, Widget? child) {
              abstractStream.setDataWithoutNotify({
                "startOpacity": opacity,
              });
              return Opacity(opacity: opacity, child: imageWidget);
            });
      } else {
        return imageWidget;
      }
    });
  }

  getAsset(
    Map<String, dynamic> parsedJson,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    Key keyWidget,
  ) {
    return Image(
      key: keyWidget,
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
  }

  getMemory(
    String imageData,
    Map<String, dynamic> parsedJson,
    DynamicUIBuilderContext dynamicUIBuilderContext,
    Key keyWidget,
  ) {
    return Image.memory(
      Util.base64Decode(imageData),
      key: keyWidget,
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

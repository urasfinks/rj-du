import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'package:rjdu/util.dart';

import '../../abstract_stream.dart';
import '../icon.dart';
import '../type_parser.dart';

class SwitchWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    AbstractStream abstractStream = getController(parsedJson, "ImageBase64Widget", dynamicUIBuilderContext, () {
      StreamData streamData = StreamData({
        "value": TypeParser.parseBool(
              getValue(parsedJson, "value", true, dynamicUIBuilderContext),
            ) ??
            true
      });
      return StreamControllerWrap(streamData, streamData.data);
    });

    String key = getValue(parsedJson, "name", "-", dynamicUIBuilderContext);
    Key xKey = Util.getKey();
    MaterialStateProperty<Icon?>? thumbIcon = getMaterialStatePropertyIcon(parsedJson, "thumbIcon", dynamicUIBuilderContext);
    MaterialStateProperty<Color?>? trackOutlineColor = getMaterialStatePropertyColor(parsedJson, "trackOutlineColor", dynamicUIBuilderContext);
    return StreamWidget.getWidget(abstractStream, (snapshot) {
      return Switch(
        key: xKey,
        value: snapshot["value"],
        onChanged: (value) {
          dynamicUIBuilderContext.dynamicPage.stateData.set(parsedJson["state"], key, value);
          click(parsedJson, dynamicUIBuilderContext, "onChanged");
          abstractStream.setData({
            "value": value,
          });
        },
        autofocus: TypeParser.parseBool(
          getValue(parsedJson, "autofocus", false, dynamicUIBuilderContext),
        )!,
        splashRadius: TypeParser.parseDouble(
          getValue(parsedJson, "splashRadius", null, dynamicUIBuilderContext),
        ),
        activeColor: TypeParser.parseColor(
          getValue(parsedJson, "activeColor", null, dynamicUIBuilderContext),
        ),
        activeTrackColor: TypeParser.parseColor(
          getValue(parsedJson, "activeTrackColor", null, dynamicUIBuilderContext),
        ),
        inactiveThumbColor: TypeParser.parseColor(
          getValue(parsedJson, "inactiveThumbColor", null, dynamicUIBuilderContext),
        ),
        inactiveTrackColor: TypeParser.parseColor(
          getValue(parsedJson, "inactiveTrackColor", null, dynamicUIBuilderContext),
        ),
        thumbIcon: thumbIcon,
        trackOutlineColor: trackOutlineColor,
      );
    });
  }

  static final Map<String, MaterialState> _mapMaterialState = TypeParser.convertEnumToMap(MaterialState.values);

  MaterialStateProperty<Icon?>? getMaterialStatePropertyIcon(
      Map<String, dynamic> parsedJson, String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (parsedJson.containsKey(key)) {
      if (parsedJson[key].runtimeType.toString().contains("Map<String,")) {
        Map<String, dynamic> materialState = parsedJson[key] as Map<String, dynamic>;
        Map<MaterialState, Icon> personalMaterialState = {};
        for (String key in materialState.keys.toList()) {
          if (_mapMaterialState.containsKey(key)) {
            personalMaterialState[_mapMaterialState[key]!] = Icon(
              iconsMap[getValue(materialState[key], "src", null, dynamicUIBuilderContext)],
              key: Util.getKey(),
              color: TypeParser.parseColor(
                getValue(materialState[key], "color", null, dynamicUIBuilderContext),
              ),
              size: TypeParser.parseDouble(
                getValue(materialState[key], "size", null, dynamicUIBuilderContext),
              ),
            );
          }
        }
        return MaterialStateProperty.resolveWith<Icon?>(
          (Set<MaterialState> states) {
            for (MaterialState materialState in states) {
              if (personalMaterialState.containsKey(materialState)) {
                return personalMaterialState[materialState];
              }
            }
            if (personalMaterialState.containsKey(MaterialState.disabled)) {
              return personalMaterialState[MaterialState.disabled];
            }
            return null;
          },
        );
      }
    }
    return null;
  }

  MaterialStateProperty<Color?>? getMaterialStatePropertyColor(
      Map<String, dynamic> parsedJson, String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (parsedJson.containsKey(key)) {
      if (parsedJson[key].runtimeType.toString().contains("Map<String,")) {
        Map<String, dynamic> materialState = parsedJson[key] as Map<String, dynamic>;
        Map<MaterialState, Color> personalMaterialState = {};
        for (String key in materialState.keys.toList()) {
          if (_mapMaterialState.containsKey(key)) {
            personalMaterialState[_mapMaterialState[key]!] = TypeParser.parseColor(
              getValue(materialState[key], "color", null, dynamicUIBuilderContext),
            ) ?? Colors.yellow;
          }
        }
        return MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            for (MaterialState materialState in states) {
              if (personalMaterialState.containsKey(materialState)) {
                return personalMaterialState[materialState];
              }
            }
            if (personalMaterialState.containsKey(MaterialState.disabled)) {
              return personalMaterialState[MaterialState.disabled];
            }
            return null;
          },
        );
      }
    }
    return null;
  }

}

import 'package:rjdu/dynamic_invoke/handler/audio_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../audio_component.dart';
import '../../util.dart';
import '../icon.dart';
import '../type_parser.dart';

class AudioButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = parsedJson["key"] ?? "Audio";
    AudioComponentContext? audioComponentContext = dynamicUIBuilderContext.dynamicPage.getPropertyFn(key, () {
      return AudioHandler().createAudioContext(parsedJson, dynamicUIBuilderContext);
    });

    if (audioComponentContext != null) {
      if (parsedJson.containsKey("autoPlayOnLoad")) {
        audioComponentContext.autoPlayOnLoad = TypeParser.parseBool(parsedJson["autoPlayOnLoad"]) ?? false;
      }

      if (TypeParser.parseBool(parsedJson["autoPlayOnInit"]) ?? false) {
        if (audioComponentContext.byteSource != null) {
          AudioComponent().play(audioComponentContext);
        } else {
          audioComponentContext.onLoadBytesCallback = (AudioComponentContext ctx) {
            AudioComponent().play(ctx);
          };
        }
      }

      return Center(
        child: Container(
            color: Colors.transparent,
            width: 50,
            height: 50,
            child: StreamBuilder(
              stream: audioComponentContext.getStream(),
              builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
                Map<String, dynamic> value = Util.overlay(
                  {"prc": 0.0, "state": AudioComponentContextState.stop.name, "playerState": ""},
                  asyncSnapshot.data,
                );

                if (!Util.isNumeric(value["prc"].toString())) {
                  value["prc"] = 0.0;
                }

                Icon icon = Icon(iconsMap["radio_button_unchecked"]);
                AudioComponentContextState audioComponentContextState =
                    TypeParser.parseAudioComponentContextState(audioComponentContext.dataState["state"]) ??
                        AudioComponentContextState.error;
                switch (audioComponentContextState) {
                  case AudioComponentContextState.stop:
                  case AudioComponentContextState.pause:
                    icon = Icon(iconsMap["play_arrow"]);
                    break;
                  case AudioComponentContextState.loading:
                    icon = Icon(iconsMap["timelapse"]);
                    break;
                  case AudioComponentContextState.play:
                    icon = Icon(iconsMap["pause"]);
                    break;
                  case AudioComponentContextState.error:
                    icon = Icon(iconsMap["error"]);
                    break;
                  default:
                    break;
                }
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    //Text(value["state"]),
                    CircularProgressIndicator(
                      value: audioComponentContextState == AudioComponentContextState.stop ? 0.0 : value["prc"],
                      key: Util.getKey(),
                      backgroundColor: TypeParser.parseColor(
                        getValue(parsedJson, "backgroundColor", "schema:onBackground", dynamicUIBuilderContext),
                      ),
                      color: TypeParser.parseColor(
                        getValue(parsedJson, "color", "schema:secondary", dynamicUIBuilderContext),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        switch (audioComponentContextState) {
                          case AudioComponentContextState.stop:
                            AudioComponent().play(audioComponentContext);
                            break;
                          case AudioComponentContextState.pause:
                            AudioComponent().resume(audioComponentContext);
                            break;
                          case AudioComponentContextState.play:
                            AudioComponent().pause();
                            break;
                          default:
                            break;
                        }
                      },
                      icon: icon,
                    ),
                  ],
                );
              },
            )),
      );
    } else {
      return const Text("AudioButtonWidget.get() Error: AudioComponentContext is null");
    }
  }
}

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rjdu/db/data_getter.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'package:rjdu/util.dart';

import 'dynamic_invoke/handler/alert_handler.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'dynamic_ui/widget/abstract_widget.dart';

class AudioComponent {
  static final AudioComponent _singleton = AudioComponent._internal();

  factory AudioComponent() {
    return _singleton;
  }

  AudioComponent._internal();

  AudioPlayer? audioPlayer;
  AudioComponentContext? audioComponentContext;

  init() async {
    Util.p("AudioComponent.init()");
    if (audioPlayer != null) {
      await audioPlayer!.stop();
      await audioPlayer!.dispose();
    }

    audioPlayer = AudioPlayer();
    if (audioComponentContext != null) {
      audioPlayer!.setAudioSource(audioComponentContext!.byteSource!);
    }
    audioPlayer!.playerStateStream.listen((event) {
      if (audioComponentContext != null) {
        PlayerState st = event;
        Map<String, dynamic> data = {
          "caller": "playerState",
          "playing": st.playing.toString(),
          "playerState": st.processingState.name.toString(),
        };
        if (st.processingState == ProcessingState.completed) {
          data["prc"] = 0.0;
          data["state"] = AudioComponentContextState.stop.name;
        }
        audioComponentContext!.streamNotify(data);
      }
    });
    audioPlayer!.bufferedPositionStream.listen((event) {
      if (audioComponentContext != null) {
        audioComponentContext!.streamNotify({
          "caller": "bufferedPosition",
          "bufferedPosition": event.toString(),
        });
      }
    });
    audioPlayer!.durationStream.listen((event) {
      Duration? ev = event;
      if (audioComponentContext != null && ev != null) {
        audioComponentContext!.streamNotify({
          "caller": "duration",
          "duration": ev.toString(),
          "durationMillis": ev.inMilliseconds,
        });
      }
    });
    audioPlayer!.positionStream.listen((event) {
      Duration ev = event;
      if (audioComponentContext != null) {
        double prc = 0;
        if (audioComponentContext!.dataState.containsKey("durationMillis")) {
          prc = ev.inMilliseconds / audioComponentContext!.dataState["durationMillis"];
        }
        audioComponentContext!.streamNotify({
          "caller": "position",
          "position": ev.toString(),
          "positionMillis": ev.inMilliseconds,
          "prc": prc,
        });
      }
    });
  }

  void play(AudioComponentContext audioComponentContext, [int tryCount = 1]) async {
    if (audioPlayer != null) {
      try {
        await audioPlayer!.stop();
      } catch (error, stackTrace) {
        Util.log("AudioComponent.play() stop() Error: $error", stackTrace: stackTrace, type: "error");
      }
      if (this.audioComponentContext != null) {
        this.audioComponentContext!.stop();
      }
      if (audioComponentContext.byteSource != null) {
        this.audioComponentContext = audioComponentContext;
        this.audioComponentContext!.loading();
        audioPlayer!.setAudioSource(audioComponentContext.byteSource!).then((value) {
          this.audioComponentContext!.play();
          audioPlayer!.play();
        }).onError((error, stackTrace) {
          Util.log("AudioComponent.play(); Error: $error", stackTrace: stackTrace, type: "error");
          this.audioComponentContext!.error(error.toString());
          if (tryCount < 3) {
            Future.delayed(const Duration(seconds: 1), () {
              play(audioComponentContext, tryCount + 1);
            });
          }
        });
      } else {
        this.audioComponentContext!.error("Файл не загружен");
      }
    } else {
      Util.log("audioPlayer is null", stack: true, type: "error");
    }
  }

  void pause() {
    if (audioComponentContext != null && audioPlayer != null) {
      audioComponentContext!.pause();
      audioPlayer!.pause();
    } else {
      Util.log("audioPlayer || audioComponentContext is null", type: "error", stack: true);
    }
  }

  void resume(AudioComponentContext audioComponentContext) {
    this.audioComponentContext = audioComponentContext;
    this.audioComponentContext!.resume();
    if (audioPlayer != null) {
      audioPlayer!.play();
    } else {
      Util.log("audioPlayer is null", type: "error", stack: true);
    }
  }

  void stop() {
    if (audioPlayer != null) {
      audioPlayer!.stop();
    } else {
      Util.log("audioPlayer is null", stack: true, type: "error");
    }
    if (audioComponentContext != null) {
      audioComponentContext!.stop();
    }
  }
}

class AudioComponentContext {
  late Map<String, dynamic> dataState;
  late StreamData _streamData;
  ByteSource? byteSource;
  bool autoPlayOnLoad = false;

  Function(AudioComponentContext audioComponentContext)? onLoadBytesCallback;

  AudioComponentContext(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext,
      [this.onLoadBytesCallback]) {
    dataState = AbstractWidget.getStateControl(args["key"] ?? "Audio", dynamicUIBuilderContext, {
      "state": AudioComponentContextState.loading.name,
      "playerState": "init",
      "bufferedPosition": "init",
      "position": "init",
    });
    try {
      switch (args["type"] ?? "undefined") {
        case "asset":
          rootBundle.load(args["src"]).then((bytes) {
            byteSource = ByteSource(bytes.buffer.asUint8List());
            streamNotify({
              "caller": "loadAsset()",
              "state": AudioComponentContextState.stop.name,
            });
            if (onLoadBytesCallback != null) {
              onLoadBytesCallback!(this);
            }
            if (autoPlayOnLoad) {
              AudioComponent().play(this);
            }
          }).onError((error, stackTrace) {
            Util.log("AudioComponentContext.constructor(); Error: $error", stackTrace: stackTrace, type: "error");
            this.error(error.toString());
          });
          break;
        case "db":
          DataGetter.getDataBlob(args["uuid"], (data) {
            if (data != null) {
              byteSource = ByteSource(data);
              streamNotify({
                "caller": "getDataBlob()",
                "state": AudioComponentContextState.stop.name,
              });
              if (onLoadBytesCallback != null) {
                onLoadBytesCallback!(this);
              }
              if (autoPlayOnLoad) {
                AudioComponent().play(this);
              }
            } else {
              streamNotify({
                "caller": "getDataBlob()",
                "state": AudioComponentContextState.error.name,
              });
            }
          });
          break;
        default:
          dataState["state"] = AudioComponentContextState.error.name;
          break;
      }
    } catch (e, stackTrace) {
      Util.log("AudioComponentContext ars: $args; onLoadBytesCallback: $onLoadBytesCallback; Error: $error",
          stackTrace: stackTrace, type: "error");
    }
    _streamData = StreamData(dataState);
  }

  void streamNotify(Map<String, dynamic> map) {
    _streamData.setData(map);
  }

  Stream getStream() {
    return _streamData.getStream();
  }

  void play() {
    streamNotify({"caller": "play()", "state": AudioComponentContextState.play.name});
  }

  void loading() {
    streamNotify({"caller": "loading()", "state": AudioComponentContextState.loading.name});
  }

  void error(String message) {
    streamNotify({"caller": "error()", "state": AudioComponentContextState.error.name});
    AlertHandler.alertSimple(message);
  }

  void pause() {
    streamNotify({"caller": "pause()", "state": AudioComponentContextState.pause.name});
  }

  void resume() {
    streamNotify({"caller": "resume()", "state": AudioComponentContextState.play.name});
  }

  void stop() {
    streamNotify({"caller": "stop()", "state": AudioComponentContextState.stop.name, "prc": 0.0});
  }
}

enum AudioComponentContextState {
  play,
  pause,
  stop,
  loading,
  error,
}

class ByteSource extends StreamAudioSource {
  final List<int> bytes;

  ByteSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

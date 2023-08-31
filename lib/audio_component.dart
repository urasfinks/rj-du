import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rjdu/db/data_getter.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'package:rjdu/util.dart';

import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'dynamic_ui/widget/abstract_widget.dart';
import 'global_settings.dart';

class AudioComponent {
  static final AudioComponent _singleton = AudioComponent._internal();

  factory AudioComponent() {
    return _singleton;
  }

  AudioComponent._internal();

  AudioPlayer audioPlayer = AudioPlayer();
  AudioComponentContext? audioComponentContext;

  init() async {
    audioPlayer.playerStateStream.listen((event) {
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
        audioComponentContext!.notifyStream(data);
      }
    });
    audioPlayer.bufferedPositionStream.listen((event) {
      if (audioComponentContext != null) {
        audioComponentContext!.notifyStream({
          "caller": "bufferedPosition",
          "bufferedPosition": event.toString(),
        });
      }
    });
    audioPlayer.durationStream.listen((event) {
      Duration? ev = event;
      if (audioComponentContext != null && ev != null) {
        audioComponentContext!.notifyStream({
          "caller": "duration",
          "duration": ev.toString(),
          "durationMillis": ev.inMilliseconds,
        });
      }
    });
    audioPlayer.positionStream.listen((event) {
      Duration ev = event;
      if (audioComponentContext != null) {
        double prc = 0;
        if (audioComponentContext!.dataState.containsKey("durationMillis")) {
          prc = ev.inMilliseconds / audioComponentContext!.dataState["durationMillis"];
        }
        audioComponentContext!.notifyStream({
          "caller": "position",
          "position": ev.toString(),
          "positionMillis": ev.inMilliseconds,
          "prc": prc,
        });
      }
    });
  }

  void play(AudioComponentContext audioComponentContext) {
    audioPlayer.stop();
    if (this.audioComponentContext != null) {
      this.audioComponentContext!.stop();
    }
    if (audioComponentContext.byteSource != null) {
      this.audioComponentContext = audioComponentContext;
      this.audioComponentContext!.loading();
      audioPlayer.setAudioSource(audioComponentContext.byteSource!).then((value) {
        this.audioComponentContext!.play();
        audioPlayer.play();
      });
    }
  }

  void pause() {
    if (audioComponentContext != null) {
      audioComponentContext!.pause();
      audioPlayer.pause();
    }
  }

  void resume(AudioComponentContext audioComponentContext) {
    this.audioComponentContext = audioComponentContext;
    this.audioComponentContext!.resume();
    audioPlayer.play();
  }

  void stop() {
    audioPlayer.stop();
    if (audioComponentContext != null) {
      audioComponentContext!.stop();
    }
  }
}

class AudioComponentContext {
  late Map<String, dynamic> dataState;
  AudioStream? _audioStream;
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
    //print("AudioComponentContext args: $args");
    try {
      switch (args["type"] ?? "undefined") {
        case "asset":
          rootBundle.load(args["src"]).then((bytes) {
            byteSource = ByteSource(bytes.buffer.asUint8List());
            notifyStream({
              "caller": "loadAsset()",
              "state": AudioComponentContextState.stop.name,
            });
            if (onLoadBytesCallback != null) {
              onLoadBytesCallback!(this);
            }
            if (autoPlayOnLoad) {
              AudioComponent().play(this);
            }
          });
          break;
        case "db":
          DataGetter.getDataBlob(args["uuid"], (data) {
            if (data != null) {
              byteSource = ByteSource(data);
              notifyStream({
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
              notifyStream({
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
    } catch (e, stacktrace) {
      if (kDebugMode) {
        debugPrintStack(
          stackTrace: stacktrace,
          maxFrames: GlobalSettings().debugStackTraceMaxFrames,
          label: "AudioComponentContext Exception: $e; ars: $args; onLoadBytesCallback: $onLoadBytesCallback",
        );
      }
    }
  }

  void notifyStream(Map<String, dynamic> map) {
    if (_audioStream != null) {
      //Util.log(map);
      Util.overlay(dataState, map);
      _audioStream!.notify();
    }
  }

  Stream getStream() {
    _audioStream = AudioStream(dataState);
    return _audioStream!.getStream();
  }

  void play() {
    notifyStream({"caller": "play()", "state": AudioComponentContextState.play.name});
  }

  void loading() {
    notifyStream({"caller": "loading()", "state": AudioComponentContextState.loading.name});
  }

  void pause() {
    notifyStream({"caller": "pause()", "state": AudioComponentContextState.pause.name});
  }

  void resume() {
    notifyStream({"caller": "resume()", "state": AudioComponentContextState.play.name});
  }

  void stop() {
    notifyStream({"caller": "stop()", "state": AudioComponentContextState.stop.name, "prc": 0.0});
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

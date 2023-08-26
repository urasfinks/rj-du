import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'package:rjdu/util.dart';

import 'dynamic_ui/dynamic_ui_builder_context.dart';

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
          "bufferedPosition": event.toString(),
        });
      }
    });
    audioPlayer.durationStream.listen((event) {
      Duration? ev = event;
      if (audioComponentContext != null && ev != null) {
        audioComponentContext!.notifyStream({
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

  AudioComponentContext(String key, String src, DynamicUIBuilderContext dynamicUIBuilderContext) {
    dataState = getStateControl(key, dynamicUIBuilderContext, {
      "state": AudioComponentContextState.stop.name,
      "playerState": "init",
      "bufferedPosition": "init",
      "position": "init",
    });

    rootBundle.load(src).then((bytes) {
      byteSource = ByteSource(bytes.buffer.asUint8List());
    });
  }

  void notifyStream(Map<String, dynamic> map) {
    if (_audioStream != null) {
      Util.overlay(dataState, map);
      _audioStream!.notify();
    }
  }

  Stream getStream() {
    _audioStream = AudioStream(dataState);
    return _audioStream!.getStream();
  }

  void play() {
    notifyStream({"state": AudioComponentContextState.play.name});
  }

  void loading() {
    notifyStream({"state": AudioComponentContextState.loading.name});
  }

  void pause() {
    notifyStream({"state": AudioComponentContextState.pause.name});
  }

  void resume() {
    notifyStream({"state": AudioComponentContextState.play.name});
  }

  void stop() {
    notifyStream({"state": AudioComponentContextState.stop.name, "prc": 0.0});
  }

  Map<String, dynamic> getStateControl(
      String key, DynamicUIBuilderContext dynamicUIBuilderContext, Map<String, dynamic> defaultState) {
    return dynamicUIBuilderContext.dynamicPage.getStateData(key, defaultState, true);
  }
}

enum AudioComponentContextState { play, pause, stop, loading }

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

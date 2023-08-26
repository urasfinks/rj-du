import 'package:just_audio/just_audio.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

import '../../rjdu.dart';

class AudioHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    play();
  }

  void play() async {
    ByteData bytes = await rootBundle.load('packages/rjdu/lib/assets/sound/file.mp3');
    //ByteData bytes = await rootBundle.load('packages/rjdu/lib/assets/sound/cut_fragment.wav');
    Uint8List soundbytes = bytes.buffer.asUint8List();

    await RjDu.player.setAudioSource(MyCustomSource(soundbytes));
    RjDu.player.play();

    RjDu.player.playerStateStream.listen((event) {
      print("playerStateStream $event");
    });
    RjDu.player.bufferedPositionStream.listen((event) {
      print("bufferedPositionStream $event");
    });
    RjDu.player.speedStream.listen((event) {
      print("speedStream $event");
    });
    RjDu.player.sequenceStateStream.listen((event) {
      print("sequenceStateStream $event");
    });
    RjDu.player.positionStream.listen((event) {
      print("positionStream $event");
    });
    RjDu.player.bufferedPositionStream.listen((event) {
      print("bufferedPositionStream $event");
    });
    RjDu.player.processingStateStream.listen((event) {
      print("processingStateStream $event");
    });
  }
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;

  MyCustomSource(this.bytes);

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

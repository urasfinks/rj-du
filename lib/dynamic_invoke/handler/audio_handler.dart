import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import '../../audio_component.dart';

class AudioHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "") {
      case "play":
        createAudioContext(args, dynamicUIBuilderContext, (AudioComponentContext audioComponentContext) {
          AudioComponent().play(audioComponentContext);
        });
        break;
      case "stop":
        AudioComponent().stop();
        break;
    }
  }

  AudioComponentContext createAudioContext(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext,
      [onLoadBytesCallback]) {
    AudioComponentContext audioComponentContext =
        AudioComponentContext(args, dynamicUIBuilderContext, onLoadBytesCallback);

    return audioComponentContext;
  }
}

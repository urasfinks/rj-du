import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import '../../audio_component.dart';

class AudioHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    createAudioContext(args, dynamicUIBuilderContext, (AudioComponentContext audioComponentContext) {
      AudioComponent().play(audioComponentContext);
    });

  }

  AudioComponentContext createAudioContext(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext, [onLoadBytesCallback]) {
    AudioComponentContext audioComponentContext =
        AudioComponentContext(args["key"], args["src"], dynamicUIBuilderContext, onLoadBytesCallback);

    return audioComponentContext;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class ImageNetworkCachedProviderProperty extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String src = getValue(parsedJson, "src", null, dynamicUIBuilderContext);
    if (!src.startsWith("http")) {
      src = "${GlobalSettings().host}$src";
    }
    return CachedNetworkImageProvider(
      src,
      maxWidth: TypeParser.parseInt(
        getValue(parsedJson, "maxWidth", null, dynamicUIBuilderContext),
      ),
      maxHeight: TypeParser.parseInt(
        getValue(parsedJson, "maxHeight", null, dynamicUIBuilderContext),
      ),
      scale: TypeParser.parseDouble(
        getValue(parsedJson, "scale", 1.0, dynamicUIBuilderContext),
      )!,
      cacheKey: getValue(parsedJson, "cacheKey", null, dynamicUIBuilderContext),
    );
  }
}

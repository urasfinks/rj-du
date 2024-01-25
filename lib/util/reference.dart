import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../util.dart';

class Reference {
  static Map<String,
          dynamic Function(Map data, Map<String, dynamic> arguments, DynamicUIBuilderContext dynamicUIBuilderContext, bool debug)>
      map = {
    "pageArgs": (data, arguments, ctx, debug) {
      Selector? selector = Util.getSelector(arguments["selector"], ctx.dynamicPage.arguments, ctx);
      if (selector != null) {
        return selector.ref;
      }
    },
  };

  static void replace(Selector? selectorReference, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (selectorReference != null && selectorReference.ref is Map && (selectorReference.ref as Map).containsKey("\$ref")) {
      String fn = selectorReference.ref["\$ref"];
      if (Reference.map.containsKey(fn)) {
        selectorReference.set(Reference.map[fn]!(data, selectorReference.ref, dynamicUIBuilderContext, false));
      }
    }
  }

  static void compileReferenceList(dynamic selector, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (selector.containsKey("replaceReferenceList")) {
      for (String path in selector["replaceReferenceList"]) {
        Selector? selectorReference = Util.getSelector(path, selector, dynamicUIBuilderContext);
        Reference.replace(selectorReference, selector, dynamicUIBuilderContext);
      }
    }
  }
}

import '../db/data.dart';
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
    "state": (data, arguments, ctx, debug) {
      Data d = ctx.dynamicPage.stateData.getInstanceData(arguments["state"]);
      Selector? selector = Util.getSelector(arguments["selector"], d.value, ctx);
      if (selector != null) {
        return selector.ref;
      }
    },
    "context": (data, arguments, ctx, debug) {
      Selector? selector = Util.getSelector(arguments["selector"], ctx.data, ctx);
      if (selector != null) {
        return selector.ref;
      }
    },
    "contextMap": (data, arguments, ctx, debug) {
      if (ctx.dynamicPage.contextMap.containsKey(arguments["contextKey"])) {
        DynamicUIBuilderContext dynamicUIBuilderContext = ctx.dynamicPage.contextMap[arguments["contextKey"]]!;
        Selector? selector = Util.getSelector(arguments["selector"], dynamicUIBuilderContext.data, ctx);
        if (selector != null) {
          return selector.ref;
        }
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
    if (selector.containsKey("compileReferenceList")) {
      for (String path in selector["compileReferenceList"]) {
        Selector? selectorReference = Util.getSelector(path, selector, dynamicUIBuilderContext);
        Reference.replace(selectorReference, selector, dynamicUIBuilderContext);
      }
    }
  }
}

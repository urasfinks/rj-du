import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../util.dart';

class Reference {
  static Map<String,
          dynamic Function(Map data, Map<String, dynamic> arguments, DynamicUIBuilderContext dynamicUIBuilderContext, bool debug)>
      map = {
    "pageArgs": (data, arguments, ctx, debug) {
      Selector? selector = get(arguments["selector"], ctx.dynamicPage.arguments, ctx);
      if (selector != null) {
        return selector.ref;
      }
    },
  };

  static Selector? get(String path, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return getByExp(path.split("."), data, dynamicUIBuilderContext);
  }

  static Selector? getByExp(List<String> exp, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Selector selector = Selector();
    selector.ref = data;
    selector.parent = data;
    for (String key in exp) {
      dynamic curKey = key;
      if (selector.ref.runtimeType == List) {
        curKey = int.parse(key);
      }
      if (selector.ref != null && selector.ref[curKey] != null) {
        selector.parent = selector.ref;
        selector.ref = selector.ref[curKey];
      }
    }
    try {
      selector.key = exp[exp.length - 1];
      if (selector.parent.runtimeType == List) {
        selector.key = int.parse(selector.key);
      }
      return selector;
    } catch (error, stackTrace) {
      Util.printStackTrace("Reference.get exp: $exp; selectorReference: $selector;", error, stackTrace);
    }
  }

  static void replace(Selector? selectorReference, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (selectorReference != null && selectorReference.ref is Map && (selectorReference.ref as Map).containsKey("\$ref")) {
      String fn = selectorReference.ref["\$ref"];
      if (Reference.map.containsKey(fn)) {
        selectorReference.set(Reference.map[fn]!(data, selectorReference.ref, dynamicUIBuilderContext, false));
      }
    }
  }

  static void replaceReferenceList(dynamic selector, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (selector.containsKey("replaceReferenceList")) {
      for (String path in selector["replaceReferenceList"]) {
        Selector? selectorReference = Reference.get(path, selector, dynamicUIBuilderContext);
        Reference.replace(selectorReference, selector, dynamicUIBuilderContext);
      }
    }
  }
}

class Selector {
  dynamic parent;
  dynamic key;
  dynamic ref;

  set(dynamic value) {
    parent[key] = value;
  }

  @override
  String toString() {
    return 'Selector{parent: $parent, key: $key, ref: $ref}';
  }
}

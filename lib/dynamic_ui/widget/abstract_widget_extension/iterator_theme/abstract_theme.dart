abstract class AbstractTheme {
  Map<String, dynamic>? getFirst();

  Map<String, dynamic>? getMiddle();

  Map<String, dynamic>? getLast();

  Map<String, dynamic>? getSingle();

  Map<String, dynamic>? getDivider();

  Map<String, dynamic>? getTemplate();

  Map<String, dynamic> getTheme() {
    Map<String, dynamic> result = {};
    dynamic x = getFirst();
    if (x != null) {
      result["templateFirst"] = x;
    }
    x = getMiddle();
    if (x != null) {
      result["templateMiddle"] = x;
    }
    x = getLast();
    if (x != null) {
      result["templateLast"] = x;
    }
    x = getDivider();
    if (x != null) {
      result["templateDivider"] = x;
    }
    x = getTemplate();
    if (x != null) {
      result["template"] = x;
    }
    x = getSingle();
    if (x != null) {
      result["templateSingle"] = x;
    }
    return result;
  }
}

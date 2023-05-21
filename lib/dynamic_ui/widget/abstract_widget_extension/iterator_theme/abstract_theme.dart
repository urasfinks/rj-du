abstract class AbstractTheme {
  Map<String, dynamic>? getFirst();

  Map<String, dynamic>? getMiddle();

  Map<String, dynamic>? getLast();

  Map<String, dynamic>? getDivider();

  Map<String, dynamic>? getTemplate();

  Map<String, dynamic> getTheme() {
    Map<String, dynamic> result = {};
    dynamic x = getFirst();
    if (x != null) {
      result["template_first"] = x;
    }
    x = getMiddle();
    if (x != null) {
      result["template_middle"] = x;
    }
    x = getLast();
    if (x != null) {
      result["template_last"] = x;
    }
    x = getDivider();
    if (x != null) {
      result["template_divider"] = x;
    }
    x = getTemplate();
    if (x != null) {
      result["template"] = x;
    }
    return result;
  }
}

enum Dictionary {
  dollar("\$"),
  curlyBraceOpen("{"),
  curlyBraceClose("}"),
  escape("\\"),
  any("*");

  final String name;

  String getName() {
    return name;
  }

  const Dictionary(this.name);

  static Dictionary parse(String ch) {
    switch (ch) {
      case "\$":
        return Dictionary.dollar;
      case "{":
        return Dictionary.curlyBraceOpen;
      case "}":
        return Dictionary.curlyBraceClose;
      case "\\":
        return Dictionary.escape;
    }
    return Dictionary.any;
  }
}

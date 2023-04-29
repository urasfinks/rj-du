import 'package:flutter/material.dart';
import '../navigator_app.dart';

class TypeParser {
  static dynamic parseFontStyle(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, FontStyle> map = {
      'normal': FontStyle.normal,
      'italic': FontStyle.italic,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static bool? parseBool(dynamic value) {
    if (value == null || value.toString().trim() == '') {
      return null;
    }
    String c = value.toString().toLowerCase();
    if (c == "true" || c == "1") {
      return true;
    }
    if (c == "false" || c == "0") {
      return false;
    }
    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value == null || value.toString().trim() == '') {
      return null;
    }
    if (value.toString() == "infinity") {
      return double.infinity;
    }
    try {
      return double.parse(value.toString());
    } catch (e) {}
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value == null || value.toString().trim() == '') {
      return null;
    }
    try {
      return int.parse(value.toString().replaceAll(".0", ""));
    } catch (e) {}
    return null;
  }

  static Map<String, Color> mapAssocNameColor = {
    "grey": Colors.grey,
    "blue": Colors.blue,
    "red": Colors.red,
    "transparent": Colors.transparent,
    "amber": Colors.amber,
    "black": Colors.black,
    "white": Colors.white,
    "yellow": Colors.yellow,
    "brown": Colors.brown,
    "cyan": Colors.cyan,
    "green": Colors.green,
    "indigo": Colors.indigo,
    "orange": Colors.orange,
    "lime": Colors.lime,
    "pink": Colors.pink,
    "purple": Colors.purple,
    "teal": Colors.teal
  };

  static Color? parseColor(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }

    if (value.startsWith("schema:")) {
      var colorScheme = Theme.of(NavigatorApp.getLast()!.context!).colorScheme;
      Map<String, dynamic> schema = {
        "primary": colorScheme.primary,
        "inversePrimary": colorScheme.inversePrimary,
        "onPrimary": colorScheme.onPrimary,
        "secondary": colorScheme.secondary,
        "onSecondary": colorScheme.onSecondary,
        "error": colorScheme.error,
        "onError": colorScheme.onError,
        "background": colorScheme.background,
        "onBackground": colorScheme.onBackground,
        "surface": colorScheme.surface,
        "onSurface": colorScheme.onSurface,
      };
      return schema[value.split(":")[1]];
    } else if (value.startsWith("rgba:")) {
      List<String> l = value.split("rgba:")[1].split(",");
      try {
        return Color.fromRGBO(parseInt(l[0])!, parseInt(l[1])!, parseInt(l[2])!,
            parseDouble(l[3])!);
      } catch (e) {}
      return Colors.pink;
    } else if (value.startsWith("#")) {
      return _parseHexColor(value);
    } else if (value.contains(".")) {
      try {
        List<String> l = value.split(".");
        MaterialColor? x = (mapAssocNameColor.containsKey(l[0])
            ? mapAssocNameColor[l[0]]
            : null) as MaterialColor?;
        if (x != null) {
          return x[parseInt(l[1])!];
        }
      } catch (e) {}
      return null;
    } else {
      return mapAssocNameColor.containsKey(value)
          ? mapAssocNameColor[value]
          : null;
    }
  }

  static Color? _parseHexColor(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    value = value.toUpperCase().replaceAll("#", "");
    if (value.length == 6) {
      value = "FF$value";
    }
    int colorInt = int.parse(value, radix: 16);
    return Color(colorInt);
  }

  static FontWeight? parseFontWeight(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, FontWeight> map = {
      "normal": FontWeight.normal,
      "bold": FontWeight.bold,
      "w100": FontWeight.w100,
      "w200": FontWeight.w200,
      "w300": FontWeight.w300,
      "w400": FontWeight.w400,
      "w500": FontWeight.w500,
      "w600": FontWeight.w600,
      "w700": FontWeight.w700,
      "w800": FontWeight.w800,
      "w900": FontWeight.w900,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static EdgeInsets? parseEdgeInsets(dynamic value) {
    //left,top,right,bottom
    if (value == null || value.toString().trim() == '') {
      return null;
    }
    var values = value.toString().split(",");
    if (values.length > 1) {
      return EdgeInsets.only(
        left: double.parse(values[0]),
        top: double.parse(values[1]),
        right: double.parse(values[2]),
        bottom: double.parse(values[3]),
      );
    } else {
      return EdgeInsets.all(parseDouble(value)!);
    }
  }

  static BoxFit? parseBoxFit(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, BoxFit> map = {
      "contain": BoxFit.contain,
      "cover": BoxFit.cover,
      "fill": BoxFit.fill,
      "fitHeight": BoxFit.fitHeight,
      "fitWidth": BoxFit.fitWidth,
      "none": BoxFit.none,
      "scaleDown": BoxFit.scaleDown,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static ImageRepeat? parseImageRepeat(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, ImageRepeat> map = {
      "noRepeat": ImageRepeat.noRepeat,
      "repeat": ImageRepeat.repeat,
      "repeatX": ImageRepeat.repeatX,
      "repeatY": ImageRepeat.repeatY
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static Alignment? parseAlignment(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, Alignment> map = {
      "center": Alignment.center,
      "centerLeft": Alignment.centerLeft,
      "centerRight": Alignment.centerRight,
      "bottomCenter": Alignment.bottomCenter,
      "bottomLeft": Alignment.bottomLeft,
      "bottomRight": Alignment.bottomRight,
      "topCenter": Alignment.topCenter,
      "topLeft": Alignment.topLeft,
      "topRight": Alignment.topRight,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static List<double>? parseListDouble(parsedJson) {
    List<double> ret = [];
    if (parsedJson != null) {
      if (parsedJson.runtimeType.toString().startsWith("List<dynamic>")) {
        for (double d in parsedJson) {
          ret.add(d);
        }
      }
      if (parsedJson.runtimeType
          .toString()
          .startsWith("_InternalLinkedHashMap<String, dynamic>")) {
        Map x = parsedJson;
        for (var item in x.entries) {
          ret.add(item.value);
        }
      }
    }
    return ret.isEmpty ? null : ret;
  }

  static List<Color> parseListColor(parsedJson) {
    List<Color> ret = [];
    if (parsedJson != null) {
      if (parsedJson.runtimeType.toString().startsWith("List<dynamic>")) {
        for (String color in parsedJson) {
          Color? x = parseColor(color);
          if (x != null) {
            ret.add(x);
          }
        }
      }
      if (parsedJson.runtimeType
          .toString()
          .startsWith("_InternalLinkedHashMap<String, dynamic>")) {
        Map x = parsedJson;
        for (var item in x.entries) {
          Color? x = parseColor(item.value);
          if (x != null) {
            ret.add(x);
          }
        }
      }
    }
    return ret;
  }

  static MainAxisAlignment? parseMainAxisAlignment(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, MainAxisAlignment> map = {
      'start': MainAxisAlignment.start,
      'center': MainAxisAlignment.center,
      'end': MainAxisAlignment.end,
      'spaceEvenly': MainAxisAlignment.spaceEvenly,
      'spaceBetween': MainAxisAlignment.spaceBetween,
      'spaceAround': MainAxisAlignment.spaceAround,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static MainAxisSize? parseMainAxisSize(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, MainAxisSize> map = {
      'min': MainAxisSize.min,
      'max': MainAxisSize.max,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static CrossAxisAlignment? parseCrossAxisAlignment(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, CrossAxisAlignment> map = {
      'start': CrossAxisAlignment.start,
      'center': CrossAxisAlignment.center,
      'end': CrossAxisAlignment.end,
      'baseline': CrossAxisAlignment.baseline,
      'stretch': CrossAxisAlignment.stretch,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static MaterialType? parseMaterialType(dynamic value) {
    switch (value) {
      case "transparency":
        return MaterialType.transparency;
      case "button":
        return MaterialType.button;
      case "canvas":
        return MaterialType.canvas;
      case "card":
        return MaterialType.card;
      case "circle":
        return MaterialType.circle;
    }
    return null;
  }

  static BorderRadius? parseBorderRadius(dynamic value) {
    if (value == null || value.toString().trim() == '') {
      return null;
    }
    if (value.toString().contains(",")) {
      List<String> l = value.toString().split(",");
      return BorderRadius.only(
        topLeft: Radius.circular(parseDouble(l[0])!),
        topRight: Radius.circular(parseDouble(l[1])!),
        bottomRight: Radius.circular(parseDouble(l[2])!),
        bottomLeft: Radius.circular(parseDouble(l[3])!),
      );
    } else {
      return BorderRadius.all(Radius.circular(parseDouble(value.toString())!));
    }
  }

  static TextInputType? parseTextInputType(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextInputType> map = {
      'none': TextInputType.none,
      'url': TextInputType.url,
      'name': TextInputType.name,
      'datetime': TextInputType.datetime,
      'time': TextInputType.text,
      'emailAddress': TextInputType.emailAddress,
      'multiline': TextInputType.multiline,
      'number': TextInputType.number,
      'phone': TextInputType.phone,
      'streetAddress': TextInputType.streetAddress,
      'text': TextInputType.text,
      'visiblePassword': TextInputType.visiblePassword
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static BorderStyle? parseBorderStyle(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, BorderStyle> map = {
      'solid': BorderStyle.solid,
      'none': BorderStyle.none,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static Axis? parseAxis(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, Axis> map = {
      'vertical': Axis.vertical,
      'horizontal': Axis.horizontal,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static Clip? parseClip(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, Clip> map = {
      'antiAlias': Clip.antiAlias,
      'antiAliasWithSaveLayer': Clip.antiAliasWithSaveLayer,
      'hardEdge': Clip.hardEdge,
      'none': Clip.none,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextBaseline? parseTextBaseline(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextBaseline> map = {
      'alphabetic': TextBaseline.alphabetic,
      'ideographic': TextBaseline.ideographic,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static AlignmentDirectional? parseAlignmentDirectional(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, AlignmentDirectional> map = {
      'bottomCenter': AlignmentDirectional.bottomCenter,
      'bottomEnd': AlignmentDirectional.bottomEnd,
      'bottomStart': AlignmentDirectional.bottomStart,
      'center': AlignmentDirectional.center,
      'centerEnd': AlignmentDirectional.centerEnd,
      'centerStart': AlignmentDirectional.centerStart,
      'topCenter': AlignmentDirectional.topCenter,
      'topEnd': AlignmentDirectional.topEnd,
      'topStart': AlignmentDirectional.topStart,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextDecoration? parseTextDecoration(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextDecoration> map = {
      'none': TextDecoration.none,
      'underline': TextDecoration.underline,
      'overline': TextDecoration.overline,
      'lineThrough': TextDecoration.lineThrough,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextDirection? parseTextDirection(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextDirection> map = {
      'ltr': TextDirection.ltr,
      'rtl': TextDirection.rtl,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static StackFit? parseStackFit(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, StackFit> map = {
      'expand': StackFit.expand,
      'loose': StackFit.loose,
      'passthrough': StackFit.passthrough,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextAlign? parseTextAlign(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextAlign> map = {
      'left': TextAlign.left,
      'start': TextAlign.start,
      'center': TextAlign.center,
      'end': TextAlign.end,
      'justify': TextAlign.justify,
      'right': TextAlign.right,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextAlignVertical? parseTextAlignVertical(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextAlignVertical> map = {
      'center': TextAlignVertical.center,
      'bottom': TextAlignVertical.bottom,
      'top': TextAlignVertical.top,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextOverflow? parseTextOverflow(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextOverflow> map = {
      'clip': TextOverflow.clip,
      'ellipsis': TextOverflow.ellipsis,
      'fade': TextOverflow.fade,
      'visible': TextOverflow.visible,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextWidthBasis? parseTextWidthBasis(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextWidthBasis> map = {
      'longestLine': TextWidthBasis.longestLine,
      'parent': TextWidthBasis.parent,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static WrapAlignment? parseWrapAlignment(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, WrapAlignment> map = {
      'end': WrapAlignment.end,
      'center': WrapAlignment.center,
      'start': WrapAlignment.start,
      'spaceAround': WrapAlignment.spaceAround,
      'spaceBetween': WrapAlignment.spaceBetween,
      'spaceEvenly': WrapAlignment.spaceEvenly,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static WrapCrossAlignment? parseWrapCrossAlignment(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, WrapCrossAlignment> map = {
      'end': WrapCrossAlignment.end,
      'center': WrapCrossAlignment.center,
      'start': WrapCrossAlignment.start,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static VerticalDirection? parseVerticalDirection(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, VerticalDirection> map = {
      'down': VerticalDirection.down,
      'up': VerticalDirection.up,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextCapitalization? parseTextCapitalization(String? value) {
    if (value == null || value.trim() == '') {
      return null;
    }
    Map<String, TextCapitalization> map = {
      'none': TextCapitalization.none,
      'characters': TextCapitalization.characters,
      'sentences': TextCapitalization.sentences,
      'words': TextCapitalization.words,
    };
    return map.containsKey(value) ? map[value] : null;
  }
}

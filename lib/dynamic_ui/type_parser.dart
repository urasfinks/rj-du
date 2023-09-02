import 'package:flutter/material.dart';
import 'package:rjdu/audio_component.dart';
import '../navigator_app.dart';
import '../subscribe_reload_group.dart';

class TypeParser {

  static final Map<String, FontStyle> _mapFontStyle = convertEnumToMap(FontStyle.values);
  static FontStyle? parseFontStyle(String? value) {
    return enumValueOf(value, _mapFontStyle);
  }

  static bool? parseBool(dynamic value) {
    if (value == null || value.toString().trim() == "") {
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
    if (value == null || value.toString().trim() == "") {
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
    if (value == null || value.toString().trim() == "") {
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

  static Color? parseColor(String? value, [BuildContext? buildContext]) {
    if (value == null || value.trim() == "") {
      return null;
    }

    if (value.startsWith("schema:")) {
      var colorScheme = Theme.of(buildContext ?? NavigatorApp.getLast()!.context!).colorScheme;
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
        return Color.fromRGBO(parseInt(l[0])!, parseInt(l[1])!, parseInt(l[2])!, parseDouble(l[3])!);
      } catch (e) {}
      return Colors.pink;
    } else if (value.startsWith("#")) {
      return _parseHexColor(value);
    } else if (value.contains(".")) {
      try {
        List<String> l = value.split(".");
        MaterialColor? x = (mapAssocNameColor.containsKey(l[0]) ? mapAssocNameColor[l[0]] : null) as MaterialColor?;
        if (x != null) {
          return x[parseInt(l[1])!];
        }
      } catch (e) {}
      return null;
    } else {
      return mapAssocNameColor.containsKey(value) ? mapAssocNameColor[value] : null;
    }
  }

  static Color? _parseHexColor(String? value) {
    if (value == null || value.trim() == "") {
      return null;
    }
    value = value.toUpperCase().replaceAll("#", "");
    if (value.length == 6) {
      value = "FF$value";
    }
    int colorInt = int.parse(value, radix: 16);
    return Color(colorInt);
  }

  static BoxShape? parseBoxShape(String? value) {
    if (value == null || value.trim() == "") {
      return null;
    }
    Map<String, BoxShape> map = {
      "circle": BoxShape.circle,
      "rectangle": BoxShape.rectangle,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static FontWeight? parseFontWeight(String? value) {
    if (value == null || value.trim() == "") {
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
    if (value == null || value.toString().trim() == "") {
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

  static final Map<String, BoxFit> _mapBoxFit = convertEnumToMap(BoxFit.values);
  static BoxFit? parseBoxFit(String? value) {
    return enumValueOf(value, _mapBoxFit);
  }

  static final Map<String, ImageRepeat> _mapImageRepeat = convertEnumToMap(ImageRepeat.values);
  static ImageRepeat? parseImageRepeat(String? value) {
    return enumValueOf(value, _mapImageRepeat);
  }

  static Alignment? parseAlignment(String? value) {
    if (value == null || value.trim() == "") {
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
      if (parsedJson.runtimeType.toString().startsWith("_InternalLinkedHashMap<String, dynamic>")) {
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
      if (parsedJson.runtimeType.toString().startsWith("_InternalLinkedHashMap<String, dynamic>")) {
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

  static final Map<String, MainAxisAlignment> _mapMainAxisAlignment = convertEnumToMap(MainAxisAlignment.values);
  static MainAxisAlignment? parseMainAxisAlignment(String? value) {
    return enumValueOf(value, _mapMainAxisAlignment);
  }

  static final Map<String, MainAxisSize> _mapMainAxisSize = convertEnumToMap(MainAxisSize.values);
  static MainAxisSize? parseMainAxisSize(String? value) {
    return enumValueOf(value, _mapMainAxisSize);
  }

  static final Map<String, CrossAxisAlignment> _mapCrossAxisAlignment = convertEnumToMap(CrossAxisAlignment.values);
  static CrossAxisAlignment? parseCrossAxisAlignment(String? value) {
    return enumValueOf(value, _mapCrossAxisAlignment);
  }

  static final Map<String, MaterialType> _mapMaterialType = convertEnumToMap(MaterialType.values);
  static MaterialType? parseMaterialType(dynamic value) {
    return enumValueOf(value, _mapMaterialType);
  }

  static BorderRadius? parseBorderRadius(dynamic value) {
    if (value == null || value.toString().trim() == "") {
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
    if (value == null || value.trim() == "") {
      return null;
    }
    Map<String, TextInputType> map = {
      "none": TextInputType.none,
      "url": TextInputType.url,
      "name": TextInputType.name,
      "datetime": TextInputType.datetime,
      "time": TextInputType.text,
      "emailAddress": TextInputType.emailAddress,
      "multiline": TextInputType.multiline,
      "number": TextInputType.number,
      "numberS": const TextInputType.numberWithOptions(signed: true, decimal: false),
      "numberD": const TextInputType.numberWithOptions(signed: false, decimal: true),
      "numberSD": const TextInputType.numberWithOptions(signed: true, decimal: true),
      "phone": TextInputType.phone,
      "streetAddress": TextInputType.streetAddress,
      "text": TextInputType.text,
      "visiblePassword": TextInputType.visiblePassword
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static final Map<String, BorderStyle> _mapBorderStyle = convertEnumToMap(BorderStyle.values);
  static BorderStyle? parseBorderStyle(String? value) {
    return enumValueOf(value, _mapBorderStyle);
  }

  static final Map<String, Axis> _mapAxis = convertEnumToMap(Axis.values);

  static Axis? parseAxis(String? value) {
    return enumValueOf(value, _mapAxis);
  }

  static final Map<String, Clip> _mapClip = convertEnumToMap(Clip.values);

  static Clip? parseClip(String? value) {
    return enumValueOf(value, _mapClip);
  }

  static final Map<String, TextBaseline> _mapTextBaseline = convertEnumToMap(TextBaseline.values);

  static TextBaseline? parseTextBaseline(String? value) {
    return enumValueOf(value, _mapTextBaseline);
  }

  static AlignmentDirectional? parseAlignmentDirectional(String? value) {
    if (value == null || value.trim() == "") {
      return null;
    }
    Map<String, AlignmentDirectional> map = {
      "bottomCenter": AlignmentDirectional.bottomCenter,
      "bottomEnd": AlignmentDirectional.bottomEnd,
      "bottomStart": AlignmentDirectional.bottomStart,
      "center": AlignmentDirectional.center,
      "centerEnd": AlignmentDirectional.centerEnd,
      "centerStart": AlignmentDirectional.centerStart,
      "topCenter": AlignmentDirectional.topCenter,
      "topEnd": AlignmentDirectional.topEnd,
      "topStart": AlignmentDirectional.topStart,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static TextDecoration? parseTextDecoration(String? value) {
    if (value == null || value.trim() == "") {
      return null;
    }
    Map<String, TextDecoration> map = {
      "none": TextDecoration.none,
      "underline": TextDecoration.underline,
      "overline": TextDecoration.overline,
      "lineThrough": TextDecoration.lineThrough,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static final Map<String, TextDirection> _mapTextDirection = convertEnumToMap(TextDirection.values);

  static TextDirection? parseTextDirection(String? value) {
    return enumValueOf(value, _mapTextDirection);
  }

  static final Map<String, StackFit> _mapStackFit = convertEnumToMap(StackFit.values);

  static StackFit? parseStackFit(String? value) {
    return enumValueOf(value, _mapStackFit);
  }

  static final Map<String, TextAlign> _mapTextAlign = convertEnumToMap(TextAlign.values);

  static TextAlign? parseTextAlign(String? value) {
    return enumValueOf(value, _mapTextAlign);
  }

  static TextAlignVertical? parseTextAlignVertical(String? value) {
    if (value == null || value.trim() == "") {
      return null;
    }
    Map<String, TextAlignVertical> map = {
      "center": TextAlignVertical.center,
      "bottom": TextAlignVertical.bottom,
      "top": TextAlignVertical.top,
    };
    return map.containsKey(value) ? map[value] : null;
  }

  static final Map<String, TextOverflow> _mapTextOverflow = convertEnumToMap(TextOverflow.values);

  static TextOverflow? parseTextOverflow(String? value) {
    return enumValueOf(value, _mapTextOverflow);
  }

  static final Map<String, TextWidthBasis> _mapTextWidthBasis = convertEnumToMap(TextWidthBasis.values);

  static TextWidthBasis? parseTextWidthBasis(String? value) {
    return enumValueOf(value, _mapTextWidthBasis);
  }

  static final Map<String, WrapAlignment> _mapWrapAlignment = convertEnumToMap(WrapAlignment.values);

  static WrapAlignment? parseWrapAlignment(String? value) {
    return enumValueOf(value, _mapWrapAlignment);
  }

  static final Map<String, WrapCrossAlignment> _mapWrapCrossAlignment = convertEnumToMap(WrapCrossAlignment.values);

  static WrapCrossAlignment? parseWrapCrossAlignment(String? value) {
    return enumValueOf(value, _mapWrapCrossAlignment);
  }

  static final Map<String, VerticalDirection> _mapVerticalDirection = convertEnumToMap(VerticalDirection.values);

  static VerticalDirection? parseVerticalDirection(String? value) {
    return enumValueOf(value, _mapVerticalDirection);
  }

  static final Map<String, TextCapitalization> _mapTextCapitalization = convertEnumToMap(TextCapitalization.values);

  static TextCapitalization? parseTextCapitalization(String? value) {
    return enumValueOf(value, _mapTextCapitalization);
  }

  static Size? parseSize(String? value) {
    if (value == null) {
      return null;
    }
    var split = value.split(",");
    return Size(parseDouble(split[0])!, parseDouble(split[1])!);
  }

  static final Map<String, SubscribeReloadGroup> _mapSubscribeReloadGroup =
      convertEnumToMap(SubscribeReloadGroup.values);

  static SubscribeReloadGroup? parseSubscribeReloadGroup(String? value) {
    return enumValueOf(value, _mapSubscribeReloadGroup);
  }

  static final Map<String, AudioComponentContextState> _mapAudioComponentContextState =
      convertEnumToMap(AudioComponentContextState.values);

  static AudioComponentContextState? parseAudioComponentContextState(String? value) {
    return enumValueOf(value, _mapAudioComponentContextState);
  }

  static Map<String, T> convertEnumToMap<T extends Enum>(List<T> list) {
    Map<String, T> result = {};
    for (T item in list) {
      result[item.name] = item;
    }
    return result;
  }

  static T? enumValueOf<T>(String? value, Map<String, T> map) {
    if (value == null || value.trim() == "") {
      return null;
    }
    return map.containsKey(value) ? map[value] : null;
  }
}

class TemplateItem {
  late final bool _isStatic;
  late final String _value;

  bool isStatic(){
    return _isStatic;
  }

  String getValue(){
    return _value;
  }

  TemplateItem(bool isStatic, String value) {
    _isStatic = isStatic;
    _value = isStatic ? value : value.substring(2, value.length - 1);
  }

  @override
  String toString() {
    return 'TemplateItem{_isStatic: $_isStatic, _value: $_value}';
  }
}

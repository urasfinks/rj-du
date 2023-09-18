import 'package:rjdu/util/template/Parser/dictionary.dart';

class Parser {
  List<Dictionary> future = [];
  Dictionary lastState = Dictionary.any;
  final Map<Dictionary, List<Dictionary>> follow = {};
  StringBuffer sb = StringBuffer();
  bool _isTerminal = false;
  bool _isFinish = false;
  bool _isParse = false;
  bool _firstEntry = false;

  Parser() {
    follow[Dictionary.dollar] = [Dictionary.curlyBraceOpen];
    follow[Dictionary.curlyBraceOpen] = [Dictionary.any, Dictionary.escape];
    follow[Dictionary.escape] = [
      Dictionary.curlyBraceOpen,
      Dictionary.curlyBraceClose,
      Dictionary.escape,
      Dictionary.dollar
    ];
    follow[Dictionary.any] = [Dictionary.any, Dictionary.curlyBraceClose, Dictionary.escape];
  }

  void read(var ch) {
    bool append = true;
    Dictionary curState = Dictionary.parse(ch);
    if (curState == Dictionary.dollar && !_isParse && lastState == Dictionary.escape) {
      var curSb = sb.toString();
      if (curSb != "") {
        sb = StringBuffer();
        sb.write(curSb.substring(0, curSb.length - 1));
      }
    }
    if (curState == Dictionary.dollar && !_isParse && lastState != Dictionary.escape) {
      _isParse = true;
      _isTerminal = true;
      setFuture(curState);
      append = false;
      _firstEntry = true;
    } else if (_isParse) {
      if (_firstEntry) {
        sb.write(Dictionary.dollar.getName());
        _firstEntry = false;
      }
      if (isMust(curState)) {
        if (curState == Dictionary.escape) {
          append = false;
        }
        if (lastState == Dictionary.escape) {
          if (curState == Dictionary.escape) {
            append = true;
          }
          setFuture(Dictionary.any);
        } else if (curState == Dictionary.curlyBraceClose) {
          _isFinish = true;
          _isParse = false;
        } else {
          setFuture(curState);
        }
      } else {
        _isTerminal = true;
        _isParse = false;
        if (curState == Dictionary.dollar) {
          append = false;
          _isParse = true;
          _firstEntry = true;
        }
      }
    }
    if (append) {
      sb.write(ch);
    }
    lastState = curState;
  }

  bool isMust(Dictionary dictionary) {
    return future.contains(dictionary);
  }

  void setFuture(Dictionary dictionary) {
    future = follow[dictionary]!;
  }

  bool isParse() {
    return _isParse;
  }

  bool isTerminal() {
    return _isTerminal;
  }

  bool isFinish() {
    return _isFinish;
  }

  String flush() {
    _isTerminal = false;
    _isFinish = false;
    String result = sb.toString();
    sb = StringBuffer();
    return result;
  }
}

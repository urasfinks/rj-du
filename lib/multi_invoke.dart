import 'dart:async';

class MultiInvoke {
  Timer? timer;
  int delayMillis = 0;

  MultiInvoke(this.delayMillis);

  void invoke(Function() callback) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: delayMillis), () {
      callback();
      timer = null;
    });
  }
}

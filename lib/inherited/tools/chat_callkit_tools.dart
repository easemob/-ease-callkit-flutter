import 'dart:math';
import 'package:flutter/foundation.dart';

bool enableLog = true;

log(String log) {
  if (enableLog) {
    debugPrint("ChatCallKit: $log");
  }
}

class ChatCallKitTools {
  static String get randomStr {
    return "flutter_${Random().nextInt(99999999).toString()}";
  }
}

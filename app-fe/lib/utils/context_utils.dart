import 'dart:io';
import 'package:flutter/material.dart';

class ContextUtils {
  static bool isMobile({
    required BuildContext context,
    double thresholdWidth = 900,
  }) {
    final sizeCheck = MediaQuery.of(context).size.width < thresholdWidth;
    return sizeCheck || (Platform.isIOS || Platform.isAndroid);
  }
}

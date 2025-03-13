import 'package:flutter/widgets.dart';

extension ColorValue on Color {
  int get hexValue {
    return _floatToInt8(alpha) << 24 |
        _floatToInt8(red) << 16 |
        _floatToInt8(green) << 8 |
        _floatToInt8(blue) << 0;
  }

  static int _floatToInt8(int x) {
    return (x * 255.0).round() & 0xff;
  }
}

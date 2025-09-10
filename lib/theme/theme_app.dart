import 'package:flutter/widgets.dart';

class ResQTheme {
  final AppPadding padding;
  final AppSize size;
  final AppColors colors;
  final AppText text;
  final AppFontWeight font;

  const ResQTheme({
    this.padding = const AppPadding(),
    this.size = const AppSize(),
    this.colors = const AppColors(),
    this.text = const AppText(),
    this.font =  const AppFontWeight()
  });
}

class AppPadding {
  const AppPadding();

  final double xs = 4.0;
  final double s = 8.0;
  final double ms = 12.0;
  final double m = 16.0;
  final double lm = 20.0;
  final double l = 24.0;
  final double xl = 28.0;
  final double xl2 = 32.0;
  final double xl3 = 36.0;
}

class AppSize {
  const AppSize();

  final double xs = 4.0;
  final double s = 8.0;
  final double ms = 12.0;
  final double m = 16.0;
  final double lm = 20.0;
  final double l = 24.0;
  final double xl = 28.0;
  final double xl2 = 32.0;
  final double xl3 = 36.0;
}

class AppColors {
  const AppColors();

  final int primary = 0xFFB71C1C;
  final NeutralColor neutral = const NeutralColor();
}

class NeutralColor {
  const NeutralColor();
  final int light = 0xFFE9E9E9;
  final int low = 0xFFD9D9D9;
  final int med = 0xFF7B7B7D;
  final int high = 0xFF3F3F3F;
}

class AppText {
  const AppText();

  final double xs = 4.0;
  final double s = 8.0;
  final double ms = 12.0;
  final double m = 16.0;
  final double lm = 20.0;
  final double l = 24.0;
  final double xl = 28.0;
  final double xl2 = 32.0;
  final double xl3 = 36.0;
}

class AppFontWeight {
  const AppFontWeight();

  final FontWeight light = FontWeight.w100;
  final FontWeight regular = FontWeight.w300;
  final FontWeight semibold = FontWeight.w500;
  final FontWeight bold = FontWeight.w700;
}
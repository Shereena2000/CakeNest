import 'package:flutter/material.dart';

import '../constants/text_styles.dart';
import 'p_colors.dart';

class PTextStyles {
    static TextStyle get displayLarge => getTextComfortaa(
    fontSize: 30,
    color: PColors.whiteColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get displayMedium => getTextComfortaa(
    fontSize: 25,
    color: PColors.whiteColor,
    fontWeight: FontWeight.bold,
  );
    static TextStyle get displaySmall => getTextComfortaa(
    fontSize: 18,
    color: PColors.blackColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get labelMedium => getTextComfortaa(
    fontSize: 16,
    color: PColors.whiteColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get labelSmall
   => getTextComfortaa(
    fontSize: 16,
    color: PColors.whiteColor,
    fontWeight: FontWeight.w500,
  );
    static TextStyle get bodyMedium
   => getTextComfortaa(
    fontSize: 14,
    color: PColors.whiteColor,
    fontWeight: FontWeight.bold,
  );
      static TextStyle get bodySmall
   => getTextComfortaa(
    fontSize: 12,
    color: PColors.whiteColor,
    fontWeight: FontWeight.w400,
  );
  // static TextStyle get displayMedium => getTextComfortaa(
  //   fontSize: 30,
  //   color: PColors.blackcolor,
  //   fontWeight: FontWeight.bold,
  // );
  // static TextStyle get titleMedium => getTextComfortaa(
  //   fontWeight: FontWeight.w600,
  //   fontSize: 20,
  //   color: PColors.blackcolor,
  // );
  // static TextStyle get displaySmall => getTextComfortaa(
  //   fontSize: 14,
  //   color: PColors.blackcolor,
  //   fontWeight: FontWeight.w400,
  // );
  // static TextStyle get bodyLarge => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 36,
  //   color: PColors.blackcolor,
  // );
  // static TextStyle get headlineLarge => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 20,
  //   color: PColors.blackcolor,
  // );

  // static TextStyle get headlineMedium => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 18,
  //   color: PColors.blackcolor,
  // );
  // static TextStyle get bodyMedium => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w400,
  //   fontSize: 16,
  //   color: PColors.blackcolor,
  // );
  // static TextStyle get headlineSmall => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 15,
  //   color: PColors.blackcolor,
  // );

  // static TextStyle get titleLarge => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.normal,
  //   fontSize: 15,
  //   color: PColors.blackcolor,
  // );

  // static TextStyle get titleSmall => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 14,
  //   color: PColors.blackcolor,
  // );

  // static TextStyle get labelSmall => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 12,
  //   color: PColors.blackcolor,
  // );
  // static TextStyle get bodySmall => TextStyle(
  //   fontFamily: 'Roboto',
  //   fontWeight: FontWeight.w500,
  //   fontSize: 10,
  //   color: PColors.blackcolor,
  // );
}

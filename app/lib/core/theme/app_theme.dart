import 'package:flutter/material.dart';

import '../vitals/reference_ranges.dart';

/// Same calm green as the rest of the LiveHealthy suite. Text is scaled up
/// slightly and touch targets are large — entering numbers is this app's
/// main job, and many users are older.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0B6E4F);

  // Flag colours: chosen to stay distinguishable for red-green colour
  // blindness when paired with the text label (the label is always shown —
  // colour is never the only signal).
  static const Color flagNormal = Color(0xFF1B7F3B);
  static const Color flagCaution = Color(0xFFB26A00);
  static const Color flagAlert = Color(0xFFC62828);

  static Color flagColor(FlagLevel level) {
    switch (level) {
      case FlagLevel.normal:
        return flagNormal;
      case FlagLevel.caution:
        return flagCaution;
      case FlagLevel.alert:
        return flagAlert;
    }
  }

  static ThemeData light() {
    // Scale the size geometry itself: ThemeData.textTheme has null font
    // sizes under Material 3 (sizes are merged in later), so applying
    // fontSizeFactor to it trips a TextStyle assertion.
    final geometry = Typography.material2021().englishLike.apply(fontSizeFactor: 1.1);
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      textTheme: geometry,
    );
    return base.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE2E8E5)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}

import 'package:flutter/material.dart';

/// Supported locales. Only English is populated today; adding a language
/// later means adding its Locale here and its string map alongside
/// [appStringsEnUS] in app_strings.dart, then registering it in
/// AppTranslations.keys.
class AppLocales {
  AppLocales._();

  static const Locale enUS = Locale('en', 'US');
  static const List<Locale> supported = [enUS];
  static const Locale fallback = enUS;
}

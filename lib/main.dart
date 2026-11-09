import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/localization/app_locales.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bindings/home_binding.dart';
import 'presentation/screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ali Raza — Mobile Product Engineer',
      theme: AppTheme.dark,
      translations: AppTranslations(),
      locale: AppLocales.fallback,
      fallbackLocale: AppLocales.fallback,
      supportedLocales: AppLocales.supported,
      debugShowCheckedModeBanner: false,
      initialBinding: HomeBinding(),
      home: const HomeScreen(),
    );
  }
}

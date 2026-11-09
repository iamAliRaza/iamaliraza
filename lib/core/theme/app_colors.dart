import 'package:flutter/material.dart';

/// Single source of truth for every color used in the app.
/// Values are pulled directly from the Figma design (no design tokens/variables
/// are defined in that file, so these raw values are authoritative).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color cardBackground = Color.fromRGBO(39, 39, 39, 0.83);
  static const Color borderSubtle = Color.fromRGBO(217, 217, 217, 0.13);
  static const Color borderStrong = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFF8A8A8A);
  // For small supporting text on cards and dialogs.
  static const Color textSecondary = Color.fromRGBO(255, 255, 255, 0.62);
  // Opaque, unlike cardBackground, so the page doesn't show through a dialog.
  static const Color dialogBackground = Color(0xFF161616);
  // cardBackground as it looks over black, but opaque for the pinned NavBar.
  static const Color navBackground = Color(0xFF202020);
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.25);
  static const Color glowWhite = Color.fromRGBO(255, 255, 255, 0.25);

  // Ambient architecture background layer (ArchitectureBackground). Neutral
  // greys by design — alpha is applied at paint time from the config, so
  // these are the fully-opaque base tones only.
  static const Color networkNode = Color(0xFFB4B4B4);
  static const Color networkLine = Color(0xFF7A7A7A);
  static const Color networkAccent = Colors.white;
}

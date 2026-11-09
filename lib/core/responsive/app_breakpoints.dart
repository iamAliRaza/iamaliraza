/// Single source of truth for responsive breakpoints.
class AppBreakpoints {
  AppBreakpoints._();

  /// Below this: phone-optimized stacked layouts.
  static const double mobile = 600;

  /// At/above this: full desktop treatment. NavBar and AboutSection key off
  /// this (not [mobile]) since their fixed-width inline content needs more
  /// room than the general phone cutoff — see ResponsiveContext.
  static const double desktop = 1024;

  /// At/above this: wide enough for all Featured project cards side by side.
  static const double wide = 1280;
}

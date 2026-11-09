import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

/// Breakpoint checks against the true viewport width ([MediaQuery.sizeOf]) —
/// unaffected by ancestor ConstrainedBox/Padding nesting, so safe to use from
/// any depth in this page's widget tree. Reads the FULL viewport width, not
/// local available space: fine for the page/section-level widgets here, but
/// don't reuse NavBar/HeroSection/etc. inside a narrower local context (a
/// modal, a card grid cell) without re-checking this assumption.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < AppBreakpoints.mobile;

  bool get isTabletOrBelow => screenWidth < AppBreakpoints.desktop;

  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;
}

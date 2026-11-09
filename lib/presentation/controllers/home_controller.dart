import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'portfolio_section.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final Map<PortfolioSection, GlobalKey> sectionKeys = {
    for (final section in PortfolioSection.values) section: GlobalKey(),
  };

  final Rx<PortfolioSection> activeSection = PortfolioSection.home.obs;

  Future<void> scrollTo(PortfolioSection section) async {
    final sectionContext = sectionKeys[section]?.currentContext;
    if (sectionContext == null) return;

    // ensureVisible already stops below the pinned NavBar sliver, and each
    // section's own top padding gives its heading room under the bar.
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    activeSection.value = section;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

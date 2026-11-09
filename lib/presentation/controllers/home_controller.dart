import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimensions.dart';
import 'portfolio_section.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final Map<PortfolioSection, GlobalKey> sectionKeys = {
    for (final section in PortfolioSection.values) section: GlobalKey(),
  };

  /// The section currently being read, for highlighting its nav link.
  final Rx<PortfolioSection> activeSection = PortfolioSection.home.obs;
  bool _syncScheduled = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scheduleActiveSectionSync);
  }

  // Scroll listeners fire before the frame is laid out, so section positions
  // would be one frame stale. Measure after the frame, at most once per frame.
  void _scheduleActiveSectionSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!isClosed) _syncActiveSection();
    });
  }

  void _syncActiveSection() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    // The last section is too short to reach the probe line on tall screens.
    if (position.pixels >= position.maxScrollExtent - 1) {
      activeSection.value = PortfolioSection.values.last;
      return;
    }

    // Sections are declared in page order, so the last one whose top has
    // passed the line just below the pinned nav is the one being read.
    var current = PortfolioSection.values.first;
    for (final section in PortfolioSection.values) {
      final box = sectionKeys[section]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      if (box.localToGlobal(Offset.zero).dy <=
          AppDimensions.activeSectionProbeY) {
        current = section;
      }
    }
    activeSection.value = current;
  }

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
  }

  @override
  void onClose() {
    scrollController.removeListener(_scheduleActiveSectionSync);
    scrollController.dispose();
    super.onClose();
  }
}

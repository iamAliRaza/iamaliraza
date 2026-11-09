import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/responsive/responsive_context.dart';
import '../controllers/home_controller.dart';
import '../controllers/portfolio_section.dart';
import '../widgets/about/about_section.dart';
import '../widgets/background/architecture_background.dart';
import '../widgets/contact/contact_section.dart';
import '../widgets/experience/experience_section.dart';
import '../widgets/footer/footer_section.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/how_i_build/how_i_build_section.dart';
import '../widgets/navbar/navbar.dart';
import '../widgets/projects/projects_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Pointer position fed to the ambient background. A ValueNotifier (rather
  /// than setState) so mouse movement never rebuilds the page — only the
  /// background's own painter reacts.
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final horizontalPadding = context.isMobile
        ? AppDimensions.spaceMd
        : AppDimensions.spaceXl;

    return Scaffold(
      // MouseRegion sits above the Stack purely to sample the pointer for the
      // background's parallax. opaque: false so it never absorbs hit-testing —
      // clicks, hovers and scrolls all still reach the content below.
      body: MouseRegion(
        opaque: false,
        onHover: (event) => _pointer.value = event.localPosition,
        onExit: (_) => _pointer.value = null,
        child: Stack(
          children: [
            // Decorative only: IgnorePointer keeps it out of hit-testing
            // entirely, and RepaintBoundary keeps its animation frames from
            // ever dirtying the content layer above it.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: ArchitectureBackground(pointer: _pointer),
                ),
              ),
            ),
            // NavBar is a pinned sliver header (rather than a Stack overlay)
            // so it stays fixed at the top while the rest of the page scrolls
            // behind it. A Stack overlay was tried first, but its NavBar sat
            // in a completely separate render/hit-test tree from the
            // SingleChildScrollView beneath it, which silently swallowed
            // mouse-wheel scrolling anywhere the nav visually covered. A
            // pinned sliver header lives inside the *same* Scrollable, so
            // there's no second hit-test tree to conflict with.
            CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedNavBarDelegate(
                    horizontalPadding: horizontalPadding,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.canvasWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KeyedSubtree(
                              key:
                                  controller.sectionKeys[PortfolioSection.home],
                              child: const HeroSection(),
                            ),
                            KeyedSubtree(
                              key: controller
                                  .sectionKeys[PortfolioSection.about],
                              child: const AboutSection(),
                            ),
                            const HowIBuildSection(),
                            KeyedSubtree(
                              key: controller
                                  .sectionKeys[PortfolioSection.experience],
                              child: const ExperienceSection(),
                            ),
                            KeyedSubtree(
                              key: controller
                                  .sectionKeys[PortfolioSection.projects],
                              child: const ProjectsSection(),
                            ),
                            KeyedSubtree(
                              key: controller
                                  .sectionKeys[PortfolioSection.contact],
                              child: const ContactSection(),
                            ),
                            const FooterSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedNavBarDelegate extends SliverPersistentHeaderDelegate {
  final double horizontalPadding;

  const _PinnedNavBarDelegate({required this.horizontalPadding});

  static const double _height =
      AppDimensions.spaceXl + AppDimensions.navBarHeight;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.canvasWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Padding(
            padding: EdgeInsets.only(top: AppDimensions.spaceXl),
            child: NavBar(),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedNavBarDelegate oldDelegate) =>
      oldDelegate.horizontalPadding != horizontalPadding;
}

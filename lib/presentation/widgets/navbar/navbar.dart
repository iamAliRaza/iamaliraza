import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/portfolio_section.dart';
import '../common/app_asset_image.dart';
import '../common/hover_builder.dart';

const _logoAsset = 'assets/icons/brand/logo.svg';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final name = Get.find<PortfolioRepository>().getProfile().name;

    return Container(
      height: AppDimensions.navBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXl),
      decoration: BoxDecoration(
        // Opaque so content scrolling behind the pinned bar can't show through.
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavLogo(
            name: name,
            onTap: () => controller.scrollTo(PortfolioSection.home),
          ),
          if (context.isTabletOrBelow)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              tooltip: 'Open navigation menu',
              onPressed: () => _openMobileMenu(controller),
            )
          else
            Row(
              children: [
                _NavLink(
                  label: 'nav_home'.tr,
                  section: PortfolioSection.home,
                  controller: controller,
                ),
                const SizedBox(width: AppDimensions.spaceXl),
                _NavLink(
                  label: 'nav_about'.tr,
                  section: PortfolioSection.about,
                  controller: controller,
                ),
                const SizedBox(width: AppDimensions.spaceXl),
                _NavLink(
                  label: 'nav_experience'.tr,
                  section: PortfolioSection.experience,
                  controller: controller,
                ),
                const SizedBox(width: AppDimensions.spaceXl),
                _NavLink(
                  label: 'nav_projects'.tr,
                  section: PortfolioSection.projects,
                  controller: controller,
                ),
                const SizedBox(width: AppDimensions.spaceXl),
                _NavLink(
                  label: 'nav_contact'.tr,
                  section: PortfolioSection.contact,
                  controller: controller,
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openMobileMenu(HomeController controller) {
    if (Get.isBottomSheetOpen == true) return;
    // GetX ignores the theme and defaults to transparent, so set both here.
    Get.bottomSheet(
      _MobileNavMenu(controller: controller),
      backgroundColor: AppColors.dialogBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusCard),
        ),
      ),
    );
  }
}

/// The site's logo: an A and R joined into one line mark. It matches the
/// favicon, and tapping it returns to the top from anywhere on the page.
class _NavLogo extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _NavLogo({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: name,
      excludeSemantics: true,
      child: Tooltip(
        message: 'nav_logo_tooltip'.tr,
        child: HoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, isHovered) {
            return GestureDetector(
              onTap: onTap,
              child: AppAssetImage(
                assetPath: _logoAsset,
                width: AppDimensions.navLogoSize,
                height: AppDimensions.navLogoSize,
                fit: BoxFit.contain,
                color: isHovered
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final PortfolioSection section;
  final HomeController controller;

  const _NavLink({
    required this.label,
    required this.section,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bold = AppTextStyles.navLink.copyWith(fontWeight: FontWeight.bold);

    return Obx(() {
      // Read here rather than in the builder below, where GetX can't see it.
      final isActive = controller.activeSection.value == section;

      return HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, isHovered) {
          return InkWell(
            onTap: () => controller.scrollTo(section),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Invisible bold copy reserves the width, so neighbouring
                // links don't shift when this one turns bold.
                ExcludeSemantics(
                  child: Opacity(
                    opacity: 0,
                    child: Text(
                      label,
                      style: bold,
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: isActive || isHovered ? bold : AppTextStyles.navLink,
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

/// The collapsed-nav bottom sheet content — one tappable row per section,
/// sized for touch (~48px). Closes the sheet before scrolling, with a short
/// delay so `Scrollable.ensureVisible` doesn't run mid-close-animation.
class _MobileNavMenu extends StatelessWidget {
  final HomeController controller;

  const _MobileNavMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Stretch, or the sheet shrinks to the width of its longest label.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MobileNavItem(
              label: 'nav_home'.tr,
              section: PortfolioSection.home,
              controller: controller,
            ),
            _MobileNavItem(
              label: 'nav_about'.tr,
              section: PortfolioSection.about,
              controller: controller,
            ),
            _MobileNavItem(
              label: 'nav_experience'.tr,
              section: PortfolioSection.experience,
              controller: controller,
            ),
            _MobileNavItem(
              label: 'nav_projects'.tr,
              section: PortfolioSection.projects,
              controller: controller,
            ),
            _MobileNavItem(
              label: 'nav_contact'.tr,
              section: PortfolioSection.contact,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String label;
  final PortfolioSection section;
  final HomeController controller;

  const _MobileNavItem({
    required this.label,
    required this.section,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
        Future.delayed(
          const Duration(milliseconds: 250),
          () => controller.scrollTo(section),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceMd,
          horizontal: AppDimensions.spaceXl,
        ),
        child: Text(
          label,
          style: AppTextStyles.navLink,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}

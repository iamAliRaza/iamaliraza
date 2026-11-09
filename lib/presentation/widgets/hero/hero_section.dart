import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/profile.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/portfolio_section.dart';
import '../common/pill_button.dart';
import '../common/social_icon_row.dart';

/// Desaturates the hero photo to match the template's black-and-white look.
const _grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<PortfolioRepository>().getProfile();

    final photoSize = context.isDesktop
        ? AppDimensions.heroPhotoSize
        : context.isMobile
        ? AppDimensions.heroPhotoSizeMobile
        : AppDimensions.heroPhotoSizeTablet;

    // The glow is drawn inside frameBuilder (rather than on an outer
    // Container wrapping the image) so it fades in together with the photo
    // instead of appearing on its own as an empty ring while the image is
    // still loading.
    Widget buildPhoto(double size) => Image.asset(
      profile.profileImageAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final decorated = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.glowWhite,
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: ColorFiltered(colorFilter: _grayscaleFilter, child: child),
          ),
        );
        if (wasSynchronouslyLoaded) return decorated;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: decorated,
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: context.isMobile
          ? Column(
              children: [
                buildPhoto(photoSize),
                const SizedBox(height: AppDimensions.spaceLg),
                _HeroText(profile: profile, centered: true),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: _HeroText(profile: profile, centered: false),
                ),
                const SizedBox(width: AppDimensions.spaceXxl),
                Expanded(
                  flex: 2,
                  // Width and height come from one value, so the column
                  // narrowing it can never turn the circle into an oval.
                  child: LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: buildPhoto(
                        math.min(constraints.maxWidth, photoSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final Profile profile;
  final bool centered;

  const _HeroText({required this.profile, required this.centered});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text('hero_meet_label'.tr, style: AppTextStyles.heroEyebrow),
        RichText(
          textAlign: centered ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: AppTextStyles.heroTitle,
            children: [
              TextSpan(
                text: '${profile.roleTitle} ',
                style: AppTextStyles.heroTitle.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              TextSpan(text: profile.name.toUpperCase()),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Text(
          profile.headline,
          style: AppTextStyles.heroHeadline,
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        Text(
          profile.heroBio,
          style: AppTextStyles.bodyRegular,
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: AppDimensions.spaceXxl),
        // One row of actions: Hire Me leads, the icons read as secondary.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PillButton(
              label: 'hire_me'.tr,
              textStyle: AppTextStyles.buttonLabelEmphasis,
              backgroundColor: AppColors.cardBackground,
              borderColor: AppColors.borderSubtle,
              hoverBackgroundColor: AppColors.background,
              hoverBorder: const Border(
                bottom: BorderSide(color: AppColors.textPrimary, width: 2),
              ),
              onPressed: () =>
                  Get.find<HomeController>().scrollTo(PortfolioSection.contact),
            ),
            const SizedBox(width: AppDimensions.spaceLg),
            const SocialIconRow(),
          ],
        ),
      ],
    );
  }
}

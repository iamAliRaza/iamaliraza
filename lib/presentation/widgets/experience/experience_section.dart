import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/experience_entry.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/bullet_text.dart';
import '../common/glass_card.dart';
import '../common/section_heading.dart';

/// Work history, newest first: one card per company with its roles grouped
/// inside, the way LinkedIn presents promotions. Not part of the Figma
/// template, so it reuses the About section's card treatment.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = Get.find<PortfolioRepository>().getExperience();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading('experience_heading'.tr),
          const SizedBox(height: AppDimensions.spaceLg),
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == entries.length - 1 ? 0 : AppDimensions.spaceLg,
              ),
              child: _CompanyCard(entry: entries[i]),
            ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final ExperienceEntry entry;

  const _CompanyCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final roles = entry.roles;

    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        enableHoverGlow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.company, style: AppTextStyles.cardHeading),
            const SizedBox(height: AppDimensions.spaceXs),
            Text(entry.location, style: AppTextStyles.projectLabel),
            const SizedBox(height: AppDimensions.spaceMd),
            if (roles.length == 1)
              _RoleContent(role: roles.first)
            else
              for (var i = 0; i < roles.length; i++)
                _TimelineRole(
                  role: roles[i],
                  isFirst: i == 0,
                  isLast: i == roles.length - 1,
                ),
          ],
        ),
      ),
    );
  }
}

/// A role in a multi-role card. The connecting line runs from dot to dot: it
/// starts at the first role's dot and ends at the last role's, and each
/// piece is positioned against the role's real height (no IntrinsicHeight,
/// which forced a too-short height on the project cards).
class _TimelineRole extends StatelessWidget {
  final ExperienceRole role;
  final bool isFirst;
  final bool isLast;

  const _TimelineRole({
    required this.role,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    const dotSize = AppDimensions.experienceTimelineDotSize;
    const dotCentre = AppDimensions.experienceTimelineDotTop + dotSize / 2;
    const lineWidth = AppDimensions.borderRegular;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: dotSize + AppDimensions.experienceTimelineIndent,
            bottom: isLast ? 0 : AppDimensions.spaceMd,
          ),
          child: _RoleContent(role: role),
        ),
        Positioned(
          left: (dotSize - lineWidth) / 2,
          width: lineWidth,
          top: isFirst ? dotCentre : 0,
          bottom: isLast ? null : 0,
          height: isLast ? dotCentre : null,
          child: const ColoredBox(color: AppColors.borderStrong),
        ),
        Positioned(
          left: 0,
          top: AppDimensions.experienceTimelineDotTop,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleContent extends StatelessWidget {
  final ExperienceRole role;

  const _RoleContent({required this.role});

  @override
  Widget build(BuildContext context) {
    final title = Text(role.title, style: AppTextStyles.bodyEmphasis);
    final period = Text(role.period, style: AppTextStyles.projectLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.isMobile) ...[
          title,
          const SizedBox(height: AppDimensions.spaceXs),
          period,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              const SizedBox(width: AppDimensions.spaceMd),
              period,
            ],
          ),
        const SizedBox(height: AppDimensions.spaceSm),
        for (final item in role.highlights) BulletText(item),
      ],
    );
  }
}

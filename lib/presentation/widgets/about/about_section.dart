import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/glass_card.dart';
import '../common/section_heading.dart';
import 'info_card.dart';
import 'skills_panel.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = Get.find<PortfolioRepository>();
    final profile = repository.getProfile();
    final education = repository.getEducation();
    final certifications = repository.getCertifications();
    final skillGroups = repository.getSkillGroups();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: GlassCard(
              enableHoverGlow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeading('about_me_heading'.tr),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Text(profile.aboutBio, style: AppTextStyles.bodyRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXl),
          _InfoCardsRow(
            stacked: context.isTabletOrBelow,
            education: InfoCard(
              heading: 'education_heading'.tr,
              items: [for (final e in education) '${e.title} — ${e.subtitle}'],
            ),
            certifications: InfoCard(
              heading: 'certifications_heading'.tr,
              items: [
                for (final c in certifications) '${c.title} — ${c.issuer}',
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          SkillsPanel(groups: skillGroups),
        ],
      ),
    );
  }
}

class _InfoCardsRow extends StatelessWidget {
  final bool stacked;
  final Widget education;
  final Widget certifications;

  const _InfoCardsRow({
    required this.stacked,
    required this.education,
    required this.certifications,
  });

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        children: [
          education,
          const SizedBox(height: AppDimensions.spaceLg),
          certifications,
        ],
      );
    }

    // IntrinsicHeight + stretch so both cards match the taller one's height
    // dynamically (by content, not a hardcoded number) rather than each
    // sizing independently to its own content.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: education),
          const SizedBox(width: AppDimensions.spaceLg),
          Expanded(child: certifications),
        ],
      ),
    );
  }
}

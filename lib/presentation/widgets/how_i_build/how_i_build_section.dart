import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workflow_overview.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/glass_card.dart';
import '../common/open_external_url.dart';
import '../common/pill_button.dart';
import '../common/section_heading.dart';

/// Shows the AI-agent delivery workflow. Every stage pairs what the agents do
/// with what stays a human decision, because that split is the point.
class HowIBuildSection extends StatelessWidget {
  const HowIBuildSection({super.key});

  int _columns(BuildContext context) {
    if (context.isMobile) return 1;
    return context.screenWidth >= AppBreakpoints.wide ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final workflow = Get.find<PortfolioRepository>().getWorkflow();
    final columns = _columns(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading('how_i_build_heading'.tr),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            workflow.intro,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          LayoutBuilder(
            builder: (context, constraints) {
              // Floored so rounding can never push the last card to a new row.
              final cardWidth =
                  ((constraints.maxWidth -
                              AppDimensions.spaceLg * (columns - 1)) /
                          columns)
                      .floorToDouble()
                      .clamp(0.0, double.infinity);
              return Wrap(
                spacing: AppDimensions.spaceLg,
                runSpacing: AppDimensions.spaceLg,
                children: [
                  for (var i = 0; i < workflow.stages.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: _StageCard(
                        number: i + 1,
                        stage: workflow.stages[i],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          PillButton(
            label: 'how_i_build_proof'.tr,
            textStyle: AppTextStyles.buttonLabelEmphasis,
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.borderSubtle,
            hoverBackgroundColor: AppColors.background,
            hoverBorder: const Border(
              bottom: BorderSide(color: AppColors.textPrimary, width: 2),
            ),
            onPressed: () => openExternalUrl(workflow.proofUrl),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final int number;
  final WorkflowStage stage;

  const _StageCard({required this.number, required this.stage});

  @override
  Widget build(BuildContext context) {
    // A minimum rather than IntrinsicHeight: cards line up, but one with more
    // text can still grow instead of overflowing.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.workflowCardMinHeight,
      ),
      child: GlassCard(
        enableHoverGlow: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Pushes "I own" to the bottom so it lines up across cards.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number.toString().padLeft(2, '0'),
                  style: AppTextStyles.projectLabel,
                ),
                const SizedBox(height: AppDimensions.spaceXs),
                Text(stage.title, style: AppTextStyles.cardHeading),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(stage.agentWork, style: AppTextStyles.bodyRegular),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spaceMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'how_i_build_i_own'.tr,
                    style: AppTextStyles.projectLabel,
                  ),
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(stage.ownership, style: AppTextStyles.bodyEmphasis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

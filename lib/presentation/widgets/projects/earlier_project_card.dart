import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/project.dart';
import '../common/glass_card.dart';
import 'project_tech_chips.dart';

/// Text-only card for older projects that no longer have a store listing or
/// images. Everything is on the card, so it deliberately has no tap action —
/// a dialog would only repeat the same text.
class EarlierProjectCard extends StatelessWidget {
  final Project project;

  const EarlierProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final label = project.label;

    return SizedBox(
      // Clamped: a near-zero viewport must not produce a negative width.
      width: (context.screenWidth - AppDimensions.projectCardViewportInset)
          .clamp(0.0, AppDimensions.earlierProjectCardWidth),
      // A minimum, not a fixed height: cards line up on desktop, but one with
      // more text (or a narrow phone) can still grow instead of overflowing.
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.earlierProjectCardMinHeight,
        ),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Pushes the chips to the bottom so they line up across cards.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: AppTextStyles.cardHeading),
                  if (label != null) ...[
                    const SizedBox(height: AppDimensions.spaceXs),
                    Text(label, style: AppTextStyles.projectLabel),
                  ],
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(project.summary, style: AppTextStyles.bodyRegular),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceMd),
                child: ProjectTechChips(tech: project.tech),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

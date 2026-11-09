import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/project.dart';
import '../common/app_asset_image.dart';
import '../common/hover_builder.dart';
import 'project_details_dialog.dart';

/// Featured project card: tapping opens its details dialog. Mirrors the Figma
/// hover variant — the card background darkens to black and the title is
/// replaced by a bold, centered "View Project" CTA.
class ProjectCard extends StatelessWidget {
  final Project project;
  final ProjectShowcase showcase;

  const ProjectCard({super.key, required this.project, required this.showcase});

  /// All Featured cards side by side on wide screens; below that a capped
  /// width, with the row scrolling and the next card peeking in on phones.
  double _cardWidth(BuildContext context) {
    final screen = context.screenWidth;
    if (screen >= AppBreakpoints.wide) {
      final available =
          math.min(screen, AppDimensions.canvasWidth) -
          AppDimensions.featuredRowChrome;
      return math.min(
        AppDimensions.projectCardWidth,
        available / AppDimensions.featuredCardsPerRow -
            AppDimensions.spaceSm * 2,
      );
    }
    // Clamped because browsers can briefly report a near-zero viewport, for
    // example while switching device mode, and a negative width crashes.
    return (screen - AppDimensions.projectCardViewportInset).clamp(
      0.0,
      AppDimensions.projectCardWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = _cardWidth(context);
    // Scales with the width so the 3-screen cover is never cropped on phones.
    final imageHeight =
        width *
        AppDimensions.projectImageHeight /
        AppDimensions.projectCardWidth;

    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, isHovered) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            onTap: () => showProjectDetails(project, showcase),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: isHovered
                    ? AppColors.background
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              ),
              child: SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAssetImage(
                      assetPath: showcase.coverAssetPath,
                      width: double.infinity,
                      height: imageHeight,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusImage,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        isHovered ? 'view_project_label'.tr : project.title,
                        textAlign: TextAlign.center,
                        style: isHovered
                            ? AppTextStyles.bodyEmphasis
                            : AppTextStyles.bodyRegular,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXs),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        showcase.proofLine,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.projectLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

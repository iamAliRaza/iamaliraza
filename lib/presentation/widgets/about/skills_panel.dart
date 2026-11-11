import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/skill.dart';
import '../common/app_asset_image.dart';
import '../common/glass_card.dart';
import '../common/horizontal_scroll_list.dart';

/// Skills in three levels of importance, so the eye has somewhere to land:
/// a highlighted AI card, the core stack as logo tiles, then quiet text lists.
class SkillsPanel extends StatelessWidget {
  final List<SkillGroup> groups;

  const SkillsPanel({super.key, required this.groups});

  List<SkillGroup> _withDisplay(SkillGroupDisplay display) =>
      groups.where((g) => g.display == display).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('skills_heading'.tr, style: AppTextStyles.cardHeading),
        const SizedBox(height: AppDimensions.spaceMd),
        for (final group in _withDisplay(SkillGroupDisplay.spotlight)) ...[
          _SpotlightCard(group: group),
          const SizedBox(height: AppDimensions.spaceLg),
        ],
        for (final group in _withDisplay(SkillGroupDisplay.tiles)) ...[
          _ScrollingTileCard(group: group),
          const SizedBox(height: AppDimensions.spaceLg),
        ],
        _ListCards(groups: _withDisplay(SkillGroupDisplay.list)),
      ],
    );
  }
}

/// Width of one item in a row of [columns], floored so rounding can never
/// wrap the last item onto a new row, and never negative on a tiny viewport.
double _itemWidth(double available, int columns, double gap) =>
    ((available - gap * (columns - 1)) / columns).floorToDouble().clamp(
      0.0,
      double.infinity,
    );

/// The highlighted card: every tile visible at once, with white logos.
class _SpotlightCard extends StatelessWidget {
  final SkillGroup group;

  const _SpotlightCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final columns = context.isDesktop ? 6 : 3;

    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        enableHoverGlow: true,
        borderColor: AppColors.borderStrong,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.title, style: AppTextStyles.cardHeading),
            const SizedBox(height: AppDimensions.spaceMd),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = _itemWidth(
                  constraints.maxWidth,
                  columns,
                  AppDimensions.spaceMd,
                );
                return Wrap(
                  spacing: AppDimensions.spaceMd,
                  runSpacing: AppDimensions.spaceMd,
                  children: [
                    for (final skill in group.skills)
                      _SkillTile(skill: skill, width: width, monochrome: true),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row of brand-colour tiles that scrolls sideways.
class _ScrollingTileCard extends StatelessWidget {
  final SkillGroup group;

  const _ScrollingTileCard({required this.group});

  // Fractional on phones so the next tile peeks in; they have no arrows.
  double _visibleTiles(BuildContext context) {
    if (context.isMobile) return 3.4;
    return context.isDesktop ? 6 : 3;
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTiles(context);
    final skills = group.skills;

    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        // Horizontal padding moves inside the scrollable, so tiles clip at
        // the card border instead of vanishing at an inset gutter.
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMd,
              ),
              child: Text(group.title, style: AppTextStyles.cardHeading),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            LayoutBuilder(
              builder: (context, constraints) {
                final inner = constraints.maxWidth - AppDimensions.spaceMd * 2;
                final width =
                    ((inner - AppDimensions.spaceMd * (visible - 1)) / visible)
                        .floorToDouble()
                        .clamp(0.0, double.infinity);
                return HorizontalScrollList(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMd,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < skills.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: i == skills.length - 1
                                ? 0
                                : AppDimensions.spaceMd,
                          ),
                          child: _SkillTile(
                            skill: skills[i],
                            width: width,
                            monochrome: false,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final Skill skill;
  final double width;

  /// Tints the logo white, for logos that sit on the site's greyscale.
  final bool monochrome;

  const _SkillTile({
    required this.skill,
    required this.width,
    required this.monochrome,
  });

  @override
  Widget build(BuildContext context) {
    final icon = skill.iconAssetPath;

    return Container(
      width: width,
      height: AppDimensions.skillTileHeight,
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusImage),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            AppAssetImage(
              assetPath: icon,
              width: AppDimensions.skillTileIconSize,
              height: AppDimensions.skillTileIconSize,
              fit: BoxFit.contain,
              color: monochrome ? AppColors.textPrimary : null,
            )
          else
            // Neutral stand-in for a skill with no published logo.
            const Icon(
              Icons.auto_awesome_outlined,
              size: AppDimensions.skillTileIconSize,
              color: AppColors.textPrimary,
            ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            skill.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.badgeLabel,
          ),
        ],
      ),
    );
  }
}

class _ListCards extends StatelessWidget {
  final List<SkillGroup> groups;

  const _ListCards({required this.groups});

  @override
  Widget build(BuildContext context) {
    final columns = context.isDesktop
        ? 4
        : context.isMobile
        ? 1
        : 2;
    final minHeight = context.isMobile
        ? 0.0
        : AppDimensions.skillListCardMinHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _itemWidth(
          constraints.maxWidth,
          columns,
          AppDimensions.spaceLg,
        );
        return Wrap(
          spacing: AppDimensions.spaceLg,
          runSpacing: AppDimensions.spaceLg,
          children: [
            for (final group in groups)
              SizedBox(
                width: width,
                // A minimum, so a longer list can still grow.
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: GlassCard(
                    enableHoverGlow: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.title, style: AppTextStyles.bodyEmphasis),
                        const SizedBox(height: AppDimensions.spaceSm),
                        for (final skill in group.skills)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spaceXs,
                            ),
                            child: Text(
                              skill.name,
                              style: AppTextStyles.bodyRegular.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Text-only tech tags, shared by the details dialog and Earlier Work cards.
/// Text rather than skill icons because projects use tech with no badge asset
/// (React Native, AppsFlyer, Geofencing...).
class ProjectTechChips extends StatelessWidget {
  final List<String> tech;

  const ProjectTechChips({super.key, required this.tech});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: [
        for (final item in tech)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceXs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Text(item, style: AppTextStyles.badgeLabel),
          ),
      ],
    );
  }
}

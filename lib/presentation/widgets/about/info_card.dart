import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../common/bullet_text.dart';
import '../common/glass_card.dart';

/// Renders a heading + bullet list inside a [GlassCard] — used for both the
/// Education and Certifications & Courses cards.
class InfoCard extends StatelessWidget {
  final String heading;
  final List<String> items;

  const InfoCard({super.key, required this.heading, required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableHoverGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: AppTextStyles.cardHeading),
          const SizedBox(height: AppDimensions.spaceMd),
          for (final item in items) BulletText(item),
        ],
      ),
    );
  }
}

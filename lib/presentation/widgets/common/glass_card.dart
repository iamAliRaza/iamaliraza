import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import 'hover_builder.dart';

/// The translucent dark bordered card reused across About cards, project
/// card frames, and contact chips. Pass [enableHoverGlow] for cards whose
/// Figma hover variant adds a white glow shadow (e.g. Education/Certifications).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final bool enableHoverGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spaceMd),
    this.borderRadius = AppDimensions.radiusCard,
    this.borderColor = AppColors.borderSubtle,
    this.borderWidth = AppDimensions.borderRegular,
    this.enableHoverGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableHoverGlow) return _buildCard(isHovered: false);

    return HoverBuilder(
      builder: (context, isHovered) => _buildCard(isHovered: isHovered),
    );
  }

  Widget _buildCard({required bool isHovered}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isHovered
            ? const [
                BoxShadow(
                  color: AppColors.glowWhite,
                  offset: Offset(0, 5),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

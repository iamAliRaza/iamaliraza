import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import 'hover_builder.dart';

/// The dark pill-shaped button for call-to-action labels (currently "Hire
/// Me"). [hoverBackgroundColor]/[hoverBorder]/[hoverTextStyle] mirror each
/// button's own Figma hover variant — they differ per button in the template
/// (e.g. one gains a full white border, Hire Me gains only a white bottom
/// border), so callers set them explicitly rather than this widget guessing a
/// single shared hover treatment.
class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextStyle textStyle;
  final TextStyle? hoverTextStyle;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? hoverBackgroundColor;
  final Color? borderColor;
  final BoxBorder? hoverBorder;
  final EdgeInsetsGeometry padding;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    required this.textStyle,
    this.hoverTextStyle,
    this.onPressed,
    this.backgroundColor = AppColors.background,
    this.hoverBackgroundColor,
    this.borderColor,
    this.hoverBorder,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceXl,
      vertical: AppDimensions.spaceMd,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorder = borderColor != null
        ? Border.all(color: borderColor!)
        : null;

    return HoverBuilder(
      cursor: onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      builder: (context, isHovered) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            onTap: onPressed,
            // The border sits outside the animation on purpose: blending an
            // all-sides border into a bottom-only one gives the sides mixed
            // colours mid-way, which Flutter can't paint on a rounded shape.
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                border: isHovered
                    ? (hoverBorder ?? defaultBorder)
                    : defaultBorder,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: padding,
                decoration: BoxDecoration(
                  color: isHovered
                      ? (hoverBackgroundColor ?? backgroundColor)
                      : backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final style = isHovered
                        ? (hoverTextStyle ?? textStyle)
                        : textStyle;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: AppDimensions.pillButtonIconSize,
                            color: style.color,
                          ),
                          const SizedBox(width: AppDimensions.spaceSm),
                        ],
                        // Flexible so a long label wraps on narrow phones.
                        Flexible(
                          child: Text(
                            label,
                            style: style,
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

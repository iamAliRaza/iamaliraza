import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// Renders an asset image — SVG via flutter_svg, everything else via
/// Image.asset — with a graceful fallback for while the real Figma assets
/// haven't been downloaded into assets/ yet (build-order phase 5). Drop the
/// fallback once every referenced asset exists — kept as a single reusable
/// spot rather than repeating errorBuilder logic per section.
class AppAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Flat color override for SVG icons (e.g. rendering a dark icon asset as
  /// white on a dark background). Ignored for raster images.
  final Color? color;

  const AppAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.color,
  });

  Widget _fallback() => Container(
    width: width,
    height: height,
    color: AppColors.imagePlaceholder,
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.imagePlaceholderIcon,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isSvg = assetPath.toLowerCase().endsWith('.svg');

    final image = isSvg
        ? SvgPicture.asset(
            assetPath,
            width: width,
            height: height,
            fit: fit,
            colorFilter: color == null
                ? null
                : ColorFilter.mode(color!, BlendMode.srcIn),
            errorBuilder: (context, error, stackTrace) => _fallback(),
          )
        : Image.asset(
            assetPath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

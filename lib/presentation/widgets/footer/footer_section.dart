import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/app_asset_image.dart';

const _flutterMark = 'assets/icons/skills/flutter.svg';
// PNG rather than SVG deliberately: every readily-available Pakistan flag SVG
// leans on chained transforms / clipPaths that flutter_svg renders wrong (it
// silently fell back to the broken-image placeholder). At a ~19px glyph a 160px
// PNG is indistinguishable and has no parser risk.
const _pakistanFlag = 'assets/icons/flags/pk.png';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  /// Inline glyph on the footer's text line. Both marks keep their own
  /// colours (the Flutter blue, the flag's green/white) rather than being
  /// tinted, so they read as the real logos.
  static WidgetSpan _glyph(
    String asset, {
    required double width,
    required double height,
    required EdgeInsets padding,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: padding,
        child: AppAssetImage(
          assetPath: asset,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<PortfolioRepository>().getProfile();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXl),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      // One centred line. It wraps on its own at narrow widths, so no
      // breakpoint branching is needed here.
      child: Center(
        child: Text.rich(
          TextSpan(
            style: AppTextStyles.footerText,
            children: <InlineSpan>[
              TextSpan(
                text:
                    '© ${DateTime.now().year} ${'footer_copyright_suffix'.tr} '
                    '| ${'footer_built_with'.tr}',
              ),
              _glyph(
                _flutterMark,
                width: AppDimensions.footerIconSize,
                height: AppDimensions.footerIconSize,
                padding: const EdgeInsets.only(left: AppDimensions.spaceXs + 2),
              ),
              const TextSpan(text: '  •  '),
              TextSpan(text: profile.name),
              _glyph(
                _pakistanFlag,
                width: AppDimensions.footerFlagWidth,
                height: AppDimensions.footerFlagHeight,
                padding: const EdgeInsets.only(left: AppDimensions.spaceXs + 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

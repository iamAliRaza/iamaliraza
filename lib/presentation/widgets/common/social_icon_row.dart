import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import 'app_asset_image.dart';
import 'open_external_url.dart';

class SocialIconRow extends StatelessWidget {
  final double iconSize;

  const SocialIconRow({
    super.key,
    this.iconSize = AppDimensions.socialIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final links = Get.find<PortfolioRepository>().getSocialLinks();

    // Sized to its icons, with spacing only between them, so a parent can
    // centre or inline the row exactly.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < links.length; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == links.length - 1 ? 0 : AppDimensions.spaceMd,
            ),
            child: InkWell(
              onTap: () => openExternalUrl(links[i].url),
              customBorder: const CircleBorder(),
              child: AppAssetImage(
                assetPath: links[i].iconAssetPath,
                width: iconSize,
                height: iconSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

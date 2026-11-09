import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../common/glass_card.dart';
import '../common/open_external_url.dart';
import '../common/pill_button.dart';
import '../common/section_heading.dart';
import '../common/social_icon_row.dart';

/// One call-to-action card. The address itself is deliberately not displayed:
/// "Email me" opens a mail app, and "Copy email" covers the many visitors who
/// don't have one set up.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.find<PortfolioRepository>().getProfile().email;
    final inset = context.isMobile
        ? AppDimensions.spaceLg
        : AppDimensions.spaceXl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading('contact_me_heading'.tr),
          const SizedBox(height: AppDimensions.spaceLg),
          SizedBox(
            width: double.infinity,
            child: GlassCard(
              enableHoverGlow: true,
              padding: EdgeInsets.all(inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_headline'.tr,
                    style: AppTextStyles.contactEmphasisText,
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(
                    'contact_subline'.tr,
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Wrap(
                    spacing: AppDimensions.spaceMd,
                    runSpacing: AppDimensions.spaceMd,
                    children: [
                      _EmailButton(email: email),
                      _CopyEmailButton(email: email),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  const Divider(
                    color: AppColors.borderSubtle,
                    height: AppDimensions.borderRegular,
                    thickness: AppDimensions.borderRegular,
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  const SocialIconRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The section's primary action, so it's the one filled button on the card.
class _EmailButton extends StatelessWidget {
  final String email;

  const _EmailButton({required this.email});

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: 'contact_email_me'.tr,
      icon: Icons.mail_outline,
      textStyle: AppTextStyles.buttonLabelEmphasis.copyWith(
        color: AppColors.background,
      ),
      hoverTextStyle: AppTextStyles.buttonLabelEmphasis,
      backgroundColor: AppColors.textPrimary,
      // Same width as the hover border's height change, so the pill doesn't
      // jump in size on hover.
      borderColor: AppColors.textPrimary,
      hoverBackgroundColor: AppColors.background,
      hoverBorder: const Border(
        bottom: BorderSide(color: AppColors.textPrimary, width: 2),
      ),
      onPressed: () => openExternalUrl('mailto:$email'),
    );
  }
}

class _CopyEmailButton extends StatefulWidget {
  final String email;

  const _CopyEmailButton({required this.email});

  @override
  State<_CopyEmailButton> createState() => _CopyEmailButtonState();
}

class _CopyEmailButtonState extends State<_CopyEmailButton> {
  static const _copiedFeedback = Duration(seconds: 2);

  bool _copied = false;
  Timer? _resetTimer;

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.email));
    } on PlatformException {
      return; // Browser refused; don't claim it was copied.
    }
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(_copiedFeedback, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: _copied ? 'contact_copied'.tr : 'contact_copy_email'.tr,
      icon: _copied ? Icons.check : Icons.content_copy,
      textStyle: AppTextStyles.buttonLabelEmphasis,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.borderSubtle,
      hoverBackgroundColor: AppColors.background,
      hoverBorder: const Border(
        bottom: BorderSide(color: AppColors.textPrimary, width: 2),
      ),
      onPressed: _copy,
    );
  }
}

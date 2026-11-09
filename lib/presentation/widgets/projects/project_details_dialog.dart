import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/project.dart';
import '../common/app_asset_image.dart';
import '../common/bullet_text.dart';
import '../common/horizontal_scroll_list.dart';
import '../common/open_external_url.dart';
import '../common/pill_button.dart';
import 'project_tech_chips.dart';

/// Opens the details dialog over the page, so the visitor keeps their scroll
/// position. Dismissed by the close button, Esc, or tapping outside.
void showProjectDetails(Project project, ProjectShowcase showcase) {
  Get.dialog<void>(_ProjectDetailsDialog(project: project, showcase: showcase));
}

class _ProjectDetailsDialog extends StatelessWidget {
  final Project project;
  final ProjectShowcase showcase;

  const _ProjectDetailsDialog({required this.project, required this.showcase});

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: _DialogContent(project: project, showcase: showcase),
    );

    if (context.isMobile) {
      return Dialog.fullscreen(
        backgroundColor: AppColors.dialogBackground,
        child: content,
      );
    }

    return Dialog(
      backgroundColor: AppColors.dialogBackground,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(AppDimensions.spaceXl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.projectDialogMaxWidth,
        ),
        child: content,
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  final Project project;
  final ProjectShowcase showcase;

  const _DialogContent({required this.project, required this.showcase});

  static const _inset = EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg);

  @override
  Widget build(BuildContext context) {
    final label = project.label;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header stays pinned so the close button is always reachable.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceLg,
            AppDimensions.spaceLg,
            AppDimensions.spaceSm,
            AppDimensions.spaceMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: AppTextStyles.sectionHeading),
                    if (label != null) ...[
                      const SizedBox(height: AppDimensions.spaceXs),
                      Text(label, style: AppTextStyles.projectLabel),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                tooltip: 'close_tooltip'.tr,
                onPressed: Get.back,
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: _inset,
                  child: Text(
                    project.summary,
                    style: AppTextStyles.bodyRegular,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                // Inset applied inside the scrollable so screenshots travel
                // to the dialog edge instead of vanishing at a gutter.
                HorizontalScrollList(
                  padding: _inset,
                  child: Row(
                    children: [
                      for (final path in showcase.screenshotAssetPaths)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: AppDimensions.spaceMd,
                          ),
                          child: AppAssetImage(
                            assetPath: path,
                            height: AppDimensions.projectGalleryHeight,
                            fit: BoxFit.contain,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                Padding(
                  padding: _inset,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'what_i_did_heading'.tr,
                        style: AppTextStyles.cardHeading,
                      ),
                      const SizedBox(height: AppDimensions.spaceSm),
                      for (final item in showcase.highlights) BulletText(item),
                      const SizedBox(height: AppDimensions.spaceSm),
                      _DialogFooter(project: project, showcase: showcase),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tech chips and store links on one slim row, so the end of the dialog stays
/// quiet. Below desktop width they stack.
class _DialogFooter extends StatelessWidget {
  final Project project;
  final ProjectShowcase showcase;

  const _DialogFooter({required this.project, required this.showcase});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final chips = ProjectTechChips(tech: project.tech);
    final actions = _StoreActions(showcase: showcase);
    final notes = [
      if (isDesktop) 'store_qr_hint'.tr,
      if (showcase.availabilityNote != null) showcase.availabilityNote!,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(child: chips),
              const SizedBox(width: AppDimensions.spaceMd),
              actions,
            ],
          )
        else ...[
          chips,
          const SizedBox(height: AppDimensions.spaceMd),
          actions,
        ],
        if (notes.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceSm),
          Text(notes, style: AppTextStyles.projectLabel),
        ],
      ],
    );
  }
}

/// One compact button per store. On desktop, where the visitor's phone is a
/// separate device, hovering a button reveals its QR code; on phones the
/// button alone opens the store.
class _StoreActions extends StatelessWidget {
  final ProjectShowcase showcase;

  const _StoreActions({required this.showcase});

  String _label(StorePlatform platform) {
    final demo = showcase.isDemoListing;
    return switch (platform) {
      StorePlatform.googlePlay => demo ? 'demo_on_play'.tr : 'view_on_play'.tr,
      StorePlatform.appStore =>
        demo ? 'demo_on_app_store'.tr : 'view_on_app_store'.tr,
    };
  }

  Widget _button(StoreLink link) {
    return PillButton(
      label: _label(link.platform),
      icon: link.platform == StorePlatform.appStore
          ? Icons.apple
          : Icons.android,
      textStyle: AppTextStyles.storeButtonLabel,
      backgroundColor: AppColors.cardBackground,
      borderColor: AppColors.borderStrong,
      hoverBackgroundColor: AppColors.background,
      hoverBorder: const Border(
        bottom: BorderSide(color: AppColors.textPrimary, width: 2),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      onPressed: () => openExternalUrl(link.url),
    );
  }

  Widget _withHoverQr(StoreLink link) {
    return Tooltip(
      preferBelow: false,
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.dialogBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusImage),
        border: Border.all(color: AppColors.borderStrong),
      ),
      richMessage: WidgetSpan(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Not tinted: a QR code needs its dark-on-white contrast to scan.
            AppAssetImage(
              assetPath: link.qrAssetPath,
              width: AppDimensions.projectQrSize,
              height: AppDimensions.projectQrSize,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              showcase.isDemoListing
                  ? 'scan_to_view_demo'.tr
                  : 'scan_to_install'.tr,
              style: AppTextStyles.projectLabel,
            ),
          ],
        ),
      ),
      child: _button(link),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: [
        for (final link in showcase.storeLinks)
          isDesktop ? _withHoverQr(link) : _button(link),
      ],
    );
  }
}

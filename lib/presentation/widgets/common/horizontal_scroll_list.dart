import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/responsive/responsive_context.dart';
import '../../../core/theme/app_colors.dart';

/// Wraps a horizontally-scrolling row (project rows, the dialog
/// gallery) with click-and-drag support for a plain desktop mouse — Flutter's
/// default [ScrollBehavior] only enables drag for touch/stylus/trackpad, not
/// a mouse, and a mouse wheel over a horizontal list scrolls the *page*.
///
/// On tablet/desktop it also overlays arrow buttons, shown only when there's
/// more to scroll that way, so mouse users can tell the row continues. Phones
/// get none: swiping is natural and the next item already peeks in.
class HorizontalScrollList extends StatefulWidget {
  final Widget child;

  /// Applied *inside* the scrollable, so the first/last item sits inset at
  /// rest but still travels all the way to the viewport edge when scrolled —
  /// which is what lets items clip cleanly against the card border instead of
  /// vanishing at an inset gutter.
  final EdgeInsetsGeometry? padding;

  const HorizontalScrollList({super.key, required this.child, this.padding});

  @override
  State<HorizontalScrollList> createState() => _HorizontalScrollListState();
}

class _HorizontalScrollListState extends State<HorizontalScrollList> {
  // Ignores sub-pixel leftovers, so a row that fits never shows an arrow.
  static const double _edgeTolerance = 1;
  static const double _pageFraction = 0.8;
  static const Duration _pageDuration = Duration(milliseconds: 350);

  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> _canScrollBack = ValueNotifier(false);
  final ValueNotifier<bool> _canScrollForward = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncArrows());
  }

  void _syncArrows() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    _canScrollBack.value = position.pixels > _edgeTolerance;
    _canScrollForward.value =
        position.pixels < position.maxScrollExtent - _edgeTolerance;
  }

  void _page(int direction) {
    final position = _controller.position;
    final target =
        (position.pixels +
                direction * position.viewportDimension * _pageFraction)
            .clamp(0.0, position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: _pageDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _canScrollBack.dispose();
    _canScrollForward.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ScrollConfiguration(
      behavior: _MouseDragScrollBehavior(),
      // Keeps the arrows right when the content or viewport size changes.
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          _syncArrows();
          return false;
        },
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    // The list keeps the same place in the tree at every width, so crossing
    // the phone breakpoint never rebuilds it or loses its scroll position.
    return Stack(
      children: [
        list,
        if (!context.isMobile) ...[
          _ArrowSlot(
            left: AppDimensions.spaceXs,
            visible: _canScrollBack,
            icon: Icons.chevron_left,
            tooltip: 'scroll_left_tooltip'.tr,
            onTap: () => _page(-1),
          ),
          _ArrowSlot(
            right: AppDimensions.spaceXs,
            visible: _canScrollForward,
            icon: Icons.chevron_right,
            tooltip: 'scroll_right_tooltip'.tr,
            onTap: () => _page(1),
          ),
        ],
      ],
    );
  }
}

class _ArrowSlot extends StatelessWidget {
  final double? left;
  final double? right;
  final ValueNotifier<bool> visible;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ArrowSlot({
    this.left,
    this.right,
    required this.visible,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: 0,
      bottom: 0,
      child: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, isVisible, _) {
            if (!isVisible) return const SizedBox.shrink();
            return Tooltip(
              message: tooltip,
              child: Material(
                color: AppColors.dialogBackground,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.borderStrong),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: SizedBox(
                    width: AppDimensions.scrollArrowSize,
                    height: AppDimensions.scrollArrowSize,
                    child: Icon(icon, color: AppColors.textPrimary),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

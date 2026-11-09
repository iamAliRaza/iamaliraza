import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';

/// Draws a small dot that chases the mouse with a slight lag. Wraps the whole
/// app (above the Navigator) so it also works over dialogs.
///
/// Mouse only, so touch devices never see it. The dot has its own painter and
/// ticker, so pointer movement never rebuilds the page, and the ticker stops
/// as soon as the dot has caught up. Off when reduced motion is requested.
class CursorFollower extends StatefulWidget {
  final Widget child;

  const CursorFollower({super.key, required this.child});

  @override
  State<CursorFollower> createState() => _CursorFollowerState();
}

class _CursorFollowerState extends State<CursorFollower>
    with SingleTickerProviderStateMixin {
  // Higher means the dot catches up faster.
  static const double _followRate = 14;
  static const double _fadeRate = 12;
  static const double _settleDistance = 0.1;
  static const double _settleOpacity = 0.01;

  late final Ticker _ticker;
  final _DotModel _dot = _DotModel();
  Duration _lastElapsed = Duration.zero;
  Offset? _target;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _wake() {
    if (_ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void _onPointer(PointerEvent event) {
    if (event.kind != PointerDeviceKind.mouse) return;
    // Below the arrow rather than on its tip, with a gap.
    final target =
        event.localPosition +
        const Offset(
          AppDimensions.cursorDotOffsetX,
          AppDimensions.cursorDotOffsetY,
        );
    // Starts in place instead of flying in from the corner.
    if (_target == null && _dot.opacity <= _settleOpacity) {
      _dot.position = target;
    }
    _target = target;
    _wake();
  }

  void _onExit(PointerExitEvent event) {
    _target = null;
    _wake();
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (dt <= 0) return;

    final target = _target;
    final targetOpacity = target == null ? 0.0 : 1.0;
    // Frame-rate independent easing.
    _dot.opacity +=
        (targetOpacity - _dot.opacity) * (1 - math.exp(-_fadeRate * dt));
    if (target != null) {
      _dot.position +=
          (target - _dot.position) * (1 - math.exp(-_followRate * dt));
    }
    _dot.changed();

    final arrived =
        target == null || (target - _dot.position).distance < _settleDistance;
    if (arrived && (targetOpacity - _dot.opacity).abs() < _settleOpacity) {
      _dot.opacity = targetOpacity;
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _dot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return MouseRegion(
      opaque: false,
      onExit: _onExit,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: _onPointer,
        onPointerMove: _onPointer,
        child: Stack(
          textDirection: TextDirection.ltr,
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _DotPainter(_dot)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotModel extends ChangeNotifier {
  Offset position = Offset.zero;
  double opacity = 0;

  void changed() => notifyListeners();
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.dot) : super(repaint: dot);

  final _DotModel dot;
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _outline = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = AppDimensions.borderRegular;

  @override
  void paint(Canvas canvas, Size size) {
    if (dot.opacity <= 0) return;
    _fill.color = AppColors.textPrimary.withValues(alpha: dot.opacity);
    // The dark edge keeps the dot visible over white buttons and tiles.
    _outline.color = AppColors.background.withValues(alpha: dot.opacity);
    canvas.drawCircle(dot.position, AppDimensions.cursorDotRadius, _fill);
    canvas.drawCircle(dot.position, AppDimensions.cursorDotRadius, _outline);
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.dot != dot;
}

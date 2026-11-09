import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import 'architecture_background_config.dart';

/// A decorative, abstract "distributed architecture" layer: clustered
/// subsystems of nodes wired by sparse links, spanned by a few large arcs,
/// sitting on soft grayscale atmosphere — drifting slowly, occasionally
/// lighting a node or routing a pulse through several hops.
///
/// Rendering contract (this is the whole reason the file is shaped this way):
/// * One [AnimationController], one [CustomPaint], one [CustomPainter] —
///   never a widget per node.
/// * The painter repaints via `super(repaint: listenable)`, so an animation
///   frame triggers **zero** widget rebuilds: no `setState`, no element-tree
///   work, just a repaint of this one surface.
/// * The whole composition (clusters, nodes, edges, arcs, atmosphere shaders,
///   adjacency) is built once per layout and never per frame. Per frame we
///   only advance scalars and re-emit geometry into reused buffers.
/// * Paint objects, alpha colour ramps and geometry buffers are precomputed,
///   and node scratch positions are mutable fields. The only per-frame
///   allocations left are the `Offset`s `Canvas.drawCircle` requires (one per
///   drawn node) plus one `Float32List` view per line tier — short-lived
///   young-generation garbage that measured at zero dropped frames. If it
///   ever matters, nodes could be bucketed by radius/alpha and batched
///   through `drawRawPoints(PointMode.points)` to remove them entirely.
/// * Links are batched into a few opacity tiers drawn with `drawRawPoints`,
///   so edge count barely affects draw-call count.
/// * No `saveLayer`, no blur, no `ImageFilter`, no shadows, no clipping. The
///   only shaders are radial gradients for the atmosphere, created once at
///   layout time.
///
/// Caller responsibilities: wrap in [RepaintBoundary] (so repaints cannot
/// dirty siblings) and [IgnorePointer] (so it never takes pointer events).
class ArchitectureBackground extends StatefulWidget {
  const ArchitectureBackground({
    super.key,
    required this.pointer,
    this.config = const ArchitectureBackgroundConfig(),
  });

  /// Pointer position in this layer's local coordinates, or null when the
  /// pointer left the surface. Driven by a [ValueNotifier] rather than a
  /// widget field so pointer movement never rebuilds anything.
  final ValueListenable<Offset?> pointer;

  final ArchitectureBackgroundConfig config;

  @override
  State<ArchitectureBackground> createState() => _ArchitectureBackgroundState();
}

class _ArchitectureBackgroundState extends State<ArchitectureBackground>
    with SingleTickerProviderStateMixin {
  late final _NetworkModel _model;
  late final AnimationController _controller;

  /// Sole repaint trigger for the painter. Notifying this marks the painter's
  /// render object dirty without touching the widget tree.
  final _RepaintSignal _repaint = _RepaintSignal();

  AppLifecycleListener? _lifecycle;

  /// Monotonic ticker reading, used to derive a wall-clock-independent dt.
  int _lastMicros = 0;

  bool _reducedMotion = false;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _model = _NetworkModel(config: widget.config);
    _controller = AnimationController(
      vsync: this,
      // Arbitrary: the controller is only a frame source. Real elapsed time
      // comes from `lastElapsedDuration`, accumulated in _onTick.
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);

    widget.pointer.addListener(_onPointerChanged);

    // On web a hidden tab already stops requestAnimationFrame, but be
    // explicit so the ticker is genuinely stopped rather than merely starved.
    // Deliberately not hooking onInactive: on web that also fires when the
    // window merely loses focus, which would freeze a still-visible page.
    _lifecycle = AppLifecycleListener(
      onHide: () => _setVisible(false),
      onPause: () => _setVisible(false),
      onShow: () => _setVisible(true),
      onResume: () => _setVisible(true),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        widget.config.respectReducedMotion &&
        MediaQuery.disableAnimationsOf(context);
    if (reduced != _reducedMotion) {
      _reducedMotion = reduced;
      _model.reducedMotion = reduced;
      _repaint.notify();
    }
    _syncTicker();
  }

  @override
  void didUpdateWidget(ArchitectureBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pointer != widget.pointer) {
      oldWidget.pointer.removeListener(_onPointerChanged);
      widget.pointer.addListener(_onPointerChanged);
    }
  }

  @override
  void dispose() {
    widget.pointer.removeListener(_onPointerChanged);
    _lifecycle?.dispose();
    _controller.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    _syncTicker();
  }

  /// Single place that decides whether frames should be produced at all.
  void _syncTicker() {
    final shouldRun = _visible && !_reducedMotion;
    if (shouldRun && !_controller.isAnimating) {
      // The ticker restarts its elapsed clock, so rebase dt tracking.
      _lastMicros = 0;
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop(canceled: false);
    }
  }

  void _onTick() {
    final micros = _controller.lastElapsedDuration?.inMicroseconds ?? 0;
    // Guard against the ticker having been restarted underneath us.
    if (micros < _lastMicros) _lastMicros = micros;
    var dt = (micros - _lastMicros) / Duration.microsecondsPerSecond;
    _lastMicros = micros;
    if (dt <= 0) return;
    // Clamp so a backgrounded tab resuming cannot teleport the animation.
    if (dt > 0.1) dt = 0.1;

    _model.advance(dt);
    _repaint.notify();
  }

  void _onPointerChanged() => _model.pointer = widget.pointer.value;

  @override
  Widget build(BuildContext context) {
    // Built once (and on config change only) — never per animation frame.
    return CustomPaint(
      painter: _NetworkPainter(model: _model, repaint: _repaint),
    );
  }
}

/// A bare [ChangeNotifier] used purely as the painter's repaint signal.
class _RepaintSignal extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─────────────────────────── composition ──────────────────────────────────

/// A cluster's placement in normalized viewport space, plus its share of the
/// total node budget. This is the "intentional composition" — deliberately
/// uneven, and shaped around the hero layout rather than spread uniformly.
@immutable
class _ClusterTemplate {
  const _ClusterTemplate(this.cx, this.cy, this.radiusFactor, this.share);
  final double cx;
  final double cy;

  /// Cluster radius as a fraction of viewport width.
  final double radiusFactor;

  /// Fraction of the node budget assigned to this cluster.
  final double share;
}

/// Wide layout: hero copy sits left, portrait right. Clusters deliberately
/// fill the dead space — top-left, below the social row, the central gap that
/// bridges copy to portrait, and the perimeter around the portrait — while
/// leaving the portrait itself clear.
/// Centres deliberately avoid the portrait disc: a cluster centred under it
/// simply gets its candidates rejected, thinning the network instead of
/// filling anything.
const List<_ClusterTemplate> _wideClusters = <_ClusterTemplate>[
  _ClusterTemplate(0.100, 0.160, 0.160, 0.155), // top-left void
  _ClusterTemplate(0.420, 0.150, 0.170, 0.170), // band between nav and copy
  _ClusterTemplate(0.160, 0.800, 0.190, 0.185), // below CTA / social icons
  _ClusterTemplate(0.470, 0.750, 0.190, 0.195), // centre, below the copy
  _ClusterTemplate(0.960, 0.320, 0.140, 0.130), // right edge, past portrait
  _ClusterTemplate(0.780, 0.920, 0.170, 0.165), // below portrait
];

/// Narrow layout: hero stacks vertically, so the composition is a simple
/// diagonal drift with no portrait exclusion.
const List<_ClusterTemplate> _narrowClusters = <_ClusterTemplate>[
  _ClusterTemplate(0.230, 0.140, 0.300, 0.340),
  _ClusterTemplate(0.760, 0.470, 0.300, 0.330),
  _ClusterTemplate(0.330, 0.850, 0.300, 0.330),
];

enum _NodeTier { ambient, active, hub }

// ───────────────────────────── model types ────────────────────────────────

class _Cluster {
  _Cluster({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.depth,
    required this.driftAmpX,
    required this.driftAmpY,
    required this.driftSpeedX,
    required this.driftSpeedY,
    required this.phaseX,
    required this.phaseY,
  });

  final double baseX;
  final double baseY;
  final double radius;
  final double depth;
  final double driftAmpX;
  final double driftAmpY;
  final double driftSpeedX;
  final double driftSpeedY;
  final double phaseX;
  final double phaseY;

  final List<int> nodes = <int>[];
  int hub = -1;

  // Per-frame coordinated drift, shared by every node in the cluster.
  double offsetX = 0;
  double offsetY = 0;
}

class _Node {
  _Node({
    required this.cluster,
    required this.tier,
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.opacity,
    required this.depth,
    required this.driftAmpX,
    required this.driftAmpY,
    required this.driftSpeedX,
    required this.driftSpeedY,
    required this.phaseX,
    required this.phaseY,
    required this.activationOffset,
    required this.activationPeriod,
  });

  final int cluster;
  final _NodeTier tier;
  final double baseX;
  final double baseY;
  final double radius;
  final double opacity;

  /// 0 = far (dim, small, barely parallaxes), 1 = near.
  final double depth;
  final double driftAmpX;
  final double driftAmpY;
  final double driftSpeedX;
  final double driftSpeedY;
  final double phaseX;
  final double phaseY;
  final double activationOffset;
  final double activationPeriod;

  // Mutable per-frame scratch — reused so frames allocate nothing.
  double x = 0;
  double y = 0;
  double activation = 0;
}

class _Connection {
  _Connection({
    required this.a,
    required this.b,
    required this.baseStrength,
    required this.breathePhase,
    required this.breatheSpeed,
    required this.isLong,
  });

  final int a;
  final int b;
  final double baseStrength;
  final double breathePhase;
  final double breatheSpeed;

  /// Long inter-cluster links are emitted as three segments so their ends
  /// read dimmer than their middle.
  final bool isLong;
}

class _Arc {
  _Arc({required this.path, required this.opacity, required this.depth});
  final Path path;
  final double opacity;
  final double depth;
}

class _Atmosphere {
  _Atmosphere({required this.paint, required this.rect, required this.depth});
  final Paint paint;
  final Rect rect;
  final double depth;
}

/// Fixed-capacity pulse: walks up to `maxPulseHops` connected edges.
class _Pulse {
  _Pulse(int maxHops)
    : route = List<int>.filled(maxHops, -1),
      from = List<int>.filled(maxHops, -1);

  /// Connection index per hop, and the node each hop starts from (so we know
  /// which way along the edge to travel).
  final List<int> route;
  final List<int> from;

  int hops = 0;
  int hop = 0;
  double progress = 0;
  double speed = 0;

  bool get active => hops > 0;
}

/// Small deterministic LCG. Avoids `Random` object churn and keeps the
/// generated composition identical across builds.
class _Rng {
  _Rng(this._state);
  int _state;

  void _advance() => _state = (_state * 1103515245 + 12345) & 0x7FFFFFFF;

  double nextDouble() {
    _advance();
    return ((_state >> 8) & 0xFFFFFF) / 0x1000000;
  }

  int nextInt(int max) {
    _advance();
    return ((_state >> 8) & 0x7FFFFF) % max;
  }

  double range(double min, double max) => min + (max - min) * nextDouble();

  /// Sum of two uniforms — cheap bell-ish distribution, used to concentrate
  /// nodes toward cluster centres instead of filling discs evenly.
  double centreBiased() => (nextDouble() + nextDouble()) * 0.5;
}

// ───────────────────────────── the model ──────────────────────────────────

class _NetworkModel {
  _NetworkModel({required this.config}) {
    _buildPalettes();
  }

  final ArchitectureBackgroundConfig config;

  final List<_Cluster> clusters = <_Cluster>[];
  final List<_Node> nodes = <_Node>[];
  final List<_Connection> connections = <_Connection>[];
  final List<_Arc> arcs = <_Arc>[];
  final List<_Atmosphere> atmosphere = <_Atmosphere>[];

  /// connection indices per node, for routing multi-hop pulses.
  final List<List<int>> adjacency = <List<int>>[];

  late final List<_Pulse> pulses = List<_Pulse>.generate(
    config.maxConcurrentPulses,
    (_) => _Pulse(config.maxPulseHops),
    growable: false,
  );

  Size size = Size.zero;
  bool parallaxEnabled = false;
  bool reducedMotion = false;
  double _pulseInterval = 1;

  double time = 0;
  double _nextPulseAt = 0;

  Offset? pointer;
  double _parallaxX = 0;
  double _parallaxY = 0;

  late final _Rng _runtime = _Rng(config.seed ^ 0x9E3779B9);

  // Precomputed alpha ramps: index instead of allocating Colors per frame.
  late final List<Color> _nodeRamp;
  late final List<Color> _haloRamp;
  late final List<Color> _lineRamp;
  late final List<Color> _arcRamp;
  late final List<Color> _pulseRamp;

  // Batched line geometry, one reusable buffer per opacity tier.
  final List<Float32List> _lineBuffers = <Float32List>[];
  final List<int> _lineCounts = <int>[];

  void _buildPalettes() {
    List<Color> ramp(Color base, double maxAlpha) => List<Color>.unmodifiable(
      List<Color>.generate(
        config.alphaSteps,
        (i) => base.withValues(alpha: maxAlpha * (i + 1) / config.alphaSteps),
      ),
    );

    _nodeRamp = ramp(AppColors.networkNode, config.nodeOpacity);
    _haloRamp = ramp(AppColors.networkAccent, config.activationHaloOpacity);
    _lineRamp = ramp(AppColors.networkLine, config.lineOpacity);
    _arcRamp = ramp(AppColors.networkLine, config.arcOpacity);
    _pulseRamp = ramp(AppColors.networkAccent, config.pulseOpacity);
  }

  Color _rampColor(List<Color> ramp, double t) {
    if (t <= 0) return ramp.first;
    var i = (t * ramp.length).floor();
    if (i >= ramp.length) i = ramp.length - 1;
    if (i < 0) i = 0;
    return ramp[i];
  }

  // ── layout: runs on size change only ───────────────────────────────────

  void layout(Size newSize) {
    size = newSize;

    // Running pulses hold indices into the old composition's connections and
    // nodes, which are about to be replaced by a different-sized set.
    for (final pulse in pulses) {
      pulse.hops = 0;
    }

    final width = newSize.width;
    final isWide = width >= AppBreakpoints.mobile;

    final count = width >= AppBreakpoints.desktop
        ? config.desktopNodeCount
        : isWide
        ? config.tabletNodeCount
        : config.mobileNodeCount;

    // Pointer parallax is a desktop-only affordance. Touch devices also never
    // emit hover events, so this is belt-and-braces.
    parallaxEnabled = width >= AppBreakpoints.desktop;
    _pulseInterval =
        config.pulseIntervalSeconds *
        (isWide ? 1.0 : config.mobilePulseIntervalMultiplier);

    final templates = isWide ? _wideClusters : _narrowClusters;

    // Keep the portrait itself clear on wide layouts; it sits right-of-centre.
    // Sized to just clear the photo plus its glow — any larger and it pushes
    // nodes out of the copy-to-portrait gap that most needs structure.
    final exclusionCentre = isWide
        ? Offset(newSize.width * 0.760, newSize.height * 0.48)
        : null;
    final exclusionRadius = math.min(
      newSize.width * 0.190,
      newSize.height * 0.360,
    );

    // Hero copy block — nodes landing here get dimmed, not removed.
    final textRect = isWide
        ? Rect.fromLTRB(
            newSize.width * 0.07,
            newSize.height * 0.24,
            newSize.width * 0.57,
            newSize.height * 0.82,
          )
        : Rect.fromLTRB(
            newSize.width * 0.10,
            newSize.height * 0.42,
            newSize.width * 0.90,
            newSize.height * 0.78,
          );

    _buildClusters(templates, newSize);
    _buildNodes(
      templates,
      count,
      newSize,
      exclusionCentre,
      exclusionRadius,
      textRect,
    );
    _buildConnections(newSize);
    _buildAdjacency();
    _buildArcs(newSize, isWide, exclusionCentre, exclusionRadius);
    _buildAtmosphere(newSize, templates);
    _allocateLineBuffers();
  }

  void _buildClusters(List<_ClusterTemplate> templates, Size size) {
    final rng = _Rng(config.seed ^ 0x00C1);
    clusters.clear();
    for (final t in templates) {
      final depth = rng.range(config.depthMin, config.depthMax);
      clusters.add(
        _Cluster(
          baseX: t.cx * size.width,
          baseY: t.cy * size.height,
          radius: t.radiusFactor * size.width,
          depth: depth,
          // Deeper clusters drift less — reinforces the depth read.
          driftAmpX: config.clusterDriftAmplitude * depth * rng.range(0.6, 1.0),
          driftAmpY: config.clusterDriftAmplitude * depth * rng.range(0.6, 1.0),
          driftSpeedX: config.clusterDriftSpeed * rng.range(0.7, 1.3),
          driftSpeedY: config.clusterDriftSpeed * rng.range(0.7, 1.3),
          phaseX: rng.range(0, math.pi * 2),
          phaseY: rng.range(0, math.pi * 2),
        ),
      );
    }
  }

  void _buildNodes(
    List<_ClusterTemplate> templates,
    int budget,
    Size size,
    Offset? exclusionCentre,
    double exclusionRadius,
    Rect textRect,
  ) {
    final rng = _Rng(config.seed);
    nodes.clear();

    final ambientCut = config.ambientNodeFraction;
    final activeCut = ambientCut + config.activeNodeFraction;
    final exclusionSq = exclusionRadius * exclusionRadius;

    bool blocked(double x, double y) {
      if (x < -20 || y < -20 || x > size.width + 20 || y > size.height + 20) {
        return true;
      }
      if (exclusionCentre == null) return false;
      final dx = x - exclusionCentre.dx;
      final dy = y - exclusionCentre.dy;
      return dx * dx + dy * dy < exclusionSq;
    }

    void addNode(double x, double y, int clusterIndex, _NodeTier? forcedTier) {
      final cluster = clusters[clusterIndex];
      final roll = rng.nextDouble();
      final tier =
          forcedTier ??
          (roll < ambientCut
              ? _NodeTier.ambient
              : roll < activeCut
              ? _NodeTier.active
              : _NodeTier.hub);

      // Node depth tracks its cluster, with a little spread for richness.
      final depth = (cluster.depth + rng.range(-0.16, 0.16)).clamp(
        config.depthMin,
        config.depthMax,
      );

      double radius;
      double tierOpacity;
      switch (tier) {
        case _NodeTier.ambient:
          radius = rng.range(config.ambientRadiusMin, config.ambientRadiusMax);
          tierOpacity = 0.55;
        case _NodeTier.active:
          radius = rng.range(config.activeRadiusMin, config.activeRadiusMax);
          tierOpacity = 0.80;
        case _NodeTier.hub:
          radius = rng.range(config.hubRadiusMin, config.hubRadiusMax);
          tierOpacity = 1.0;
      }
      // Nearer nodes read a touch larger and brighter.
      radius *= 0.8 + 0.35 * depth;
      var opacity = tierOpacity * (0.5 + 0.5 * depth);
      if (textRect.contains(Offset(x, y))) {
        opacity *= config.textAreaDimming;
      }

      final index = nodes.length;
      nodes.add(
        _Node(
          cluster: clusterIndex,
          tier: tier,
          baseX: x,
          baseY: y,
          radius: radius,
          opacity: opacity.clamp(0.0, 1.0),
          depth: depth,
          driftAmpX: config.nodeDriftAmplitude * rng.range(0.4, 1.0),
          driftAmpY: config.nodeDriftAmplitude * rng.range(0.4, 1.0),
          driftSpeedX: config.nodeDriftSpeed * rng.range(0.6, 1.5),
          driftSpeedY: config.nodeDriftSpeed * rng.range(0.6, 1.5),
          phaseX: rng.range(0, math.pi * 2),
          phaseY: rng.range(0, math.pi * 2),
          // Activation timing is per-cluster, so subsystems light up as a
          // region rather than as scattered individual nodes.
          activationOffset:
              (clusterIndex / clusters.length + rng.range(-0.05, 0.05) + 1) %
              1.0,
          activationPeriod: rng.range(
            config.activationPeriodMin,
            config.activationPeriodMax,
          ),
        ),
      );
      cluster.nodes.add(index);
      if (tier == _NodeTier.hub && cluster.hub < 0) cluster.hub = index;
    }

    // ── clustered nodes ──
    final clusterBudget = (budget * config.clusterBudgetFraction).round();
    for (var c = 0; c < clusters.length; c++) {
      final cluster = clusters[c];
      final want = (clusterBudget * templates[c].share).round();

      var placed = 0;
      var attempts = 0;
      while (placed < want && attempts < want * 30) {
        attempts++;
        // Centre-biased polar placement: denser cores, sparse edges.
        final angle = rng.range(0, math.pi * 2);
        final r = cluster.radius * rng.centreBiased();
        final x = cluster.baseX + math.cos(angle) * r;
        final y = cluster.baseY + math.sin(angle) * r * 0.85;
        if (blocked(x, y)) continue;
        addNode(x, y, c, null);
        placed++;
      }

      // Every cluster needs an anchor for inter-cluster wiring and arcs.
      if (cluster.hub < 0 && cluster.nodes.isNotEmpty) {
        cluster.hub = cluster.nodes.first;
      }
    }

    // ── ambient scatter ──
    // Fills the gaps between clusters and, critically, makes up any shortfall
    // where cluster candidates were rejected — so the budget is always met.
    var remaining = budget - nodes.length;
    var attempts = 0;
    while (remaining > 0 && attempts < budget * 40) {
      attempts++;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      if (blocked(x, y)) continue;

      // Attach to the nearest cluster so scattered dust still drifts with the
      // system rather than floating independently.
      var nearest = 0;
      var nearestSq = double.infinity;
      for (var c = 0; c < clusters.length; c++) {
        final dx = clusters[c].baseX - x;
        final dy = clusters[c].baseY - y;
        final dsq = dx * dx + dy * dy;
        if (dsq < nearestSq) {
          nearestSq = dsq;
          nearest = c;
        }
      }
      addNode(x, y, nearest, _NodeTier.ambient);
      remaining--;
    }
  }

  /// Intra-cluster wiring uses a uniform spatial grid so each node only tests
  /// the 3x3 cell neighbourhood that could hold an in-range partner, rather
  /// than every other node. Inter-cluster wiring is hub-to-hub only, which is
  /// what produces the occasional long architectural span.
  void _buildConnections(Size size) {
    connections.clear();
    if (nodes.length < 2) return;

    final rng = _Rng(config.seed ^ 0x1234);
    final maxDist = size.width * config.intraClusterDistanceFactor;
    final maxDistSq = maxDist * maxDist;
    final taken = <int>{};
    final candidates = <(int, double)>[];

    void addLink(int i, int j, double dist, double reference, bool isLong) {
      final key = i < j ? i * 8192 + j : j * 8192 + i;
      if (!taken.add(key)) return;
      final falloff = (1 - dist / reference).clamp(0.0, 1.0);
      connections.add(
        _Connection(
          a: i,
          b: j,
          baseStrength: isLong ? 0.30 : 0.40 + 0.60 * falloff * falloff,
          breathePhase: rng.range(0, math.pi * 2),
          breatheSpeed: config.connectionBreatheSpeed * rng.range(0.6, 1.5),
          isLong: isLong,
        ),
      );
    }

    // ── intra-cluster ──
    final cols = math.max(1, (size.width / maxDist).ceil());
    final rows = math.max(1, (size.height / maxDist).ceil());
    final buckets = List<List<int>>.generate(cols * rows, (_) => <int>[]);

    int cellOf(double x, double y) {
      final cx = (x / maxDist).floor().clamp(0, cols - 1);
      final cy = (y / maxDist).floor().clamp(0, rows - 1);
      return cy * cols + cx;
    }

    for (var i = 0; i < nodes.length; i++) {
      buckets[cellOf(nodes[i].baseX, nodes[i].baseY)].add(i);
    }

    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final cx = (n.baseX / maxDist).floor().clamp(0, cols - 1);
      final cy = (n.baseY / maxDist).floor().clamp(0, rows - 1);

      candidates.clear();
      for (var dy = -1; dy <= 1; dy++) {
        final by = cy + dy;
        if (by < 0 || by >= rows) continue;
        for (var dx = -1; dx <= 1; dx++) {
          final bx = cx + dx;
          if (bx < 0 || bx >= cols) continue;
          for (final j in buckets[by * cols + bx]) {
            if (j == i) continue;
            final o = nodes[j];
            // Same-cluster only: keeps subsystems legible as subsystems.
            if (o.cluster != n.cluster) continue;
            final ddx = o.baseX - n.baseX;
            final ddy = o.baseY - n.baseY;
            final dsq = ddx * ddx + ddy * ddy;
            if (dsq > maxDistSq) continue;
            candidates.add((j, dsq));
          }
        }
      }

      candidates.sort((a, b) => a.$2.compareTo(b.$2));
      final keep = math.min(config.intraClusterLinks, candidates.length);
      for (var k = 0; k < keep; k++) {
        addLink(
          i,
          candidates[k].$1,
          math.sqrt(candidates[k].$2),
          maxDist,
          false,
        );
      }
    }

    // ── inter-cluster: a couple of long spans between neighbouring clusters ──
    final diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    for (var a = 0; a < clusters.length; a++) {
      final from = clusters[a];
      if (from.hub < 0) continue;
      // Order the other clusters by proximity and wire the nearest few.
      final others = <(int, double)>[];
      for (var b = 0; b < clusters.length; b++) {
        if (b == a) continue;
        final to = clusters[b];
        if (to.hub < 0) continue;
        final dx = to.baseX - from.baseX;
        final dy = to.baseY - from.baseY;
        others.add((b, dx * dx + dy * dy));
      }
      others.sort((x, y) => x.$2.compareTo(y.$2));
      final links = math.min(config.interClusterLinks, others.length);
      for (var k = 0; k < links; k++) {
        final to = clusters[others[k].$1];
        addLink(from.hub, to.hub, math.sqrt(others[k].$2), diagonal, true);
      }
    }
  }

  void _buildAdjacency() {
    adjacency.clear();
    for (var i = 0; i < nodes.length; i++) {
      adjacency.add(<int>[]);
    }
    for (var c = 0; c < connections.length; c++) {
      adjacency[connections[c].a].add(c);
      adjacency[connections[c].b].add(c);
    }
  }

  /// A few very faint large-radius curves reading as abstract system
  /// boundaries / data routes. Geometry is static; only alpha and parallax
  /// vary, so there is nothing to rebuild per frame.
  void _buildArcs(
    Size size,
    bool isWide,
    Offset? exclusionCentre,
    double exclusionRadius,
  ) {
    arcs.clear();
    final rng = _Rng(config.seed ^ 0x0A2C);

    // Bowed spans between well-separated cluster hubs.
    final pairs = <(int, int)>[];
    for (var a = 0; a < clusters.length; a++) {
      for (var b = a + 1; b < clusters.length; b++) {
        if (clusters[a].hub < 0 || clusters[b].hub < 0) continue;
        pairs.add((a, b));
      }
    }
    pairs.sort((p, q) {
      double span((int, int) pair) {
        final dx = clusters[pair.$1].baseX - clusters[pair.$2].baseX;
        final dy = clusters[pair.$1].baseY - clusters[pair.$2].baseY;
        return dx * dx + dy * dy;
      }

      return span(q).compareTo(span(p));
    });

    final wanted = math.min(config.arcCount, pairs.length);
    for (var i = 0; i < wanted; i++) {
      final a = clusters[pairs[i].$1];
      final b = clusters[pairs[i].$2];
      final mx = (a.baseX + b.baseX) / 2;
      final my = (a.baseY + b.baseY) / 2;
      final dx = b.baseX - a.baseX;
      final dy = b.baseY - a.baseY;
      final bow = config.arcBowFactor * (i.isEven ? 1 : -1);
      // Control point pushed perpendicular to the chord.
      final path = Path()
        ..moveTo(a.baseX, a.baseY)
        ..quadraticBezierTo(mx - dy * bow, my + dx * bow, b.baseX, b.baseY);
      arcs.add(
        _Arc(
          path: path,
          opacity: rng.range(0.55, 1.0),
          depth: rng.range(config.depthMin, 0.6),
        ),
      );
    }

    // One sweep hugging the portrait, so the photo reads as part of the system.
    if (isWide && exclusionCentre != null) {
      final r = exclusionRadius * 1.10;
      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: exclusionCentre, radius: r),
          -math.pi * 0.78,
          math.pi * 1.15,
          true,
        );
      arcs.add(_Arc(path: path, opacity: 0.85, depth: 0.35));
    }
  }

  /// Soft grayscale radial fields so the black stops reading as flat. Shaders
  /// are created here (once per layout), never per frame, and there is no
  /// blur or saveLayer involved.
  void _buildAtmosphere(Size size, List<_ClusterTemplate> templates) {
    atmosphere.clear();
    final rng = _Rng(config.seed ^ 0x0BEE);
    final count = math.min(config.atmosphereCount, templates.length);

    for (var i = 0; i < count; i++) {
      // Anchor to the larger clusters so light sits where structure is.
      final t = templates[i * templates.length ~/ count];
      final centre = Offset(t.cx * size.width, t.cy * size.height);
      final radius =
          size.width * config.atmosphereRadiusFactor * rng.range(0.75, 1.15);
      final rect = Rect.fromCircle(center: centre, radius: radius);
      final alpha = config.atmosphereOpacity * rng.range(0.7, 1.0);
      final shader = RadialGradient(
        colors: <Color>[
          AppColors.networkAccent.withValues(alpha: alpha),
          AppColors.networkAccent.withValues(alpha: alpha * 0.35),
          AppColors.networkAccent.withValues(alpha: 0),
        ],
        stops: const <double>[0.0, 0.45, 1.0],
      ).createShader(rect);
      atmosphere.add(
        _Atmosphere(
          paint: Paint()..shader = shader,
          rect: rect,
          depth: rng.range(0.10, 0.28),
        ),
      );
    }
  }

  void _allocateLineBuffers() {
    _lineBuffers.clear();
    _lineCounts.clear();
    // Long links emit 3 segments; 2 points x 2 coords per segment.
    final capacity = connections.length * 3 * 4;
    for (var i = 0; i < config.lineTierCount; i++) {
      _lineBuffers.add(Float32List(capacity));
      _lineCounts.add(0);
    }
  }

  // ── per-frame advance: scalars only ────────────────────────────────────

  void advance(double dt) {
    time += dt;
    _advanceParallax(dt);
    _advancePulses(dt);
  }

  void _advanceParallax(double dt) {
    double targetX = 0;
    double targetY = 0;
    final p = pointer;
    if (parallaxEnabled && p != null && !size.isEmpty) {
      // Counter-move the network against the cursor: reads as depth rather
      // than as the layer chasing the pointer.
      targetX = -((p.dx / size.width) * 2 - 1) * config.parallaxStrength;
      targetY = -((p.dy / size.height) * 2 - 1) * config.parallaxStrength;
    }
    // Frame-rate independent exponential smoothing.
    final k = 1 - math.exp(-config.parallaxEasing * dt);
    _parallaxX += (targetX - _parallaxX) * k;
    _parallaxY += (targetY - _parallaxY) * k;
  }

  void _advancePulses(double dt) {
    for (final pulse in pulses) {
      if (!pulse.active) continue;
      pulse.progress += pulse.speed * dt;
      while (pulse.progress >= 1) {
        pulse.progress -= 1;
        pulse.hop++;
        if (pulse.hop >= pulse.hops) {
          pulse.hops = 0;
          break;
        }
      }
    }

    if (connections.isEmpty || time < _nextPulseAt) return;
    _nextPulseAt = time + _pulseInterval * _runtime.range(0.7, 1.6);
    for (final pulse in pulses) {
      if (pulse.active) continue;
      _spawnPulse(pulse);
      break;
    }
  }

  /// Routes a pulse through 1..maxPulseHops connected edges, so it reads as
  /// data traversing the architecture rather than blinking on one line.
  void _spawnPulse(_Pulse pulse) {
    var node = _runtime.nextInt(nodes.length);
    if (adjacency[node].isEmpty) {
      // One cheap retry rather than a scan; pulses are decorative.
      node = _runtime.nextInt(nodes.length);
      if (adjacency[node].isEmpty) return;
    }

    final hops = 1 + _runtime.nextInt(config.maxPulseHops);
    var count = 0;
    var previous = -1;
    for (var h = 0; h < hops; h++) {
      final edges = adjacency[node];
      if (edges.isEmpty) break;
      var pick = edges[_runtime.nextInt(edges.length)];
      // Try not to immediately double back along the edge we arrived on.
      if (pick == previous && edges.length > 1) {
        pick = edges[_runtime.nextInt(edges.length)];
      }
      final conn = connections[pick];
      pulse.route[count] = pick;
      pulse.from[count] = node;
      count++;
      previous = pick;
      node = conn.a == node ? conn.b : conn.a;
    }
    if (count == 0) return;

    pulse.hops = count;
    pulse.hop = 0;
    pulse.progress = 0;
    pulse.speed = config.pulseSpeed * _runtime.range(0.8, 1.25);
  }

  /// Resolves cluster offsets, node positions and activation for this frame.
  void updateFrame() {
    final animate = !reducedMotion;
    final t = time;
    final px = animate ? _parallaxX : 0.0;
    final py = animate ? _parallaxY : 0.0;
    final duty = config.activationDutyCycle;

    for (var i = 0; i < clusters.length; i++) {
      final c = clusters[i];
      if (!animate) {
        c.offsetX = 0;
        c.offsetY = 0;
        continue;
      }
      c.offsetX = math.sin(t * c.driftSpeedX + c.phaseX) * c.driftAmpX;
      c.offsetY = math.cos(t * c.driftSpeedY + c.phaseY) * c.driftAmpY;
    }

    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final cluster = clusters[n.cluster];
      if (!animate) {
        n.x = n.baseX;
        n.y = n.baseY;
        n.activation = 0;
        continue;
      }
      // Cluster drift dominates; the node's own wobble is a small accent.
      n.x =
          n.baseX +
          cluster.offsetX +
          math.sin(t * n.driftSpeedX + n.phaseX) * n.driftAmpX +
          px * n.depth;
      n.y =
          n.baseY +
          cluster.offsetY +
          math.cos(t * n.driftSpeedY + n.phaseY) * n.driftAmpY +
          py * n.depth;

      // Narrow bump within each node's cycle: lit for `duty` of the period,
      // dormant the rest, so most of the network is quiet at any instant.
      final phase = (t / n.activationPeriod + n.activationOffset) % 1.0;
      n.activation = phase < duty ? math.sin(phase / duty * math.pi) : 0.0;
    }
  }

  /// Fills the per-tier line buffers for this frame. The painter reads
  /// [_lineBuffers]/[_lineCounts] immediately afterwards.
  void buildLineBatches() {
    if (_lineBuffers.isEmpty) return;
    for (var i = 0; i < _lineCounts.length; i++) {
      _lineCounts[i] = 0;
    }

    final tiers = config.lineTierCount;
    final animate = !reducedMotion;
    final t = time;
    final fade = config.longLinkEndFadeRatio;

    void emit(double x1, double y1, double x2, double y2, double strength) {
      if (strength <= 0.02) return;
      var tier = (strength.clamp(0.0, 1.0) * tiers).floor();
      if (tier >= tiers) tier = tiers - 1;
      final buffer = _lineBuffers[tier];
      final offset = _lineCounts[tier] * 4;
      if (offset + 3 >= buffer.length) return;
      buffer[offset] = x1;
      buffer[offset + 1] = y1;
      buffer[offset + 2] = x2;
      buffer[offset + 3] = y2;
      _lineCounts[tier]++;
    }

    for (var c = 0; c < connections.length; c++) {
      final conn = connections[c];
      final a = nodes[conn.a];
      final b = nodes[conn.b];

      var strength = conn.baseStrength;
      if (animate) {
        strength *=
            0.62 + 0.38 * math.sin(t * conn.breatheSpeed + conn.breathePhase);
        final act = a.activation > b.activation ? a.activation : b.activation;
        if (act > 0) strength += act * config.activationLineBoost;
      }
      if (strength <= 0.02) continue;

      if (!conn.isLong) {
        emit(a.x, a.y, b.x, b.y, strength);
        continue;
      }

      // Three segments: dim, full, dim — an end-fade with no gradient shader.
      final dx = b.x - a.x;
      final dy = b.y - a.y;
      final p1x = a.x + dx * fade;
      final p1y = a.y + dy * fade;
      final p2x = a.x + dx * (1 - fade);
      final p2y = a.y + dy * (1 - fade);
      emit(a.x, a.y, p1x, p1y, strength * 0.35);
      emit(p1x, p1y, p2x, p2y, strength);
      emit(p2x, p2y, b.x, b.y, strength * 0.35);
    }
  }

  double get parallaxX => reducedMotion ? 0 : _parallaxX;
  double get parallaxY => reducedMotion ? 0 : _parallaxY;
}

// ───────────────────────────── painter ────────────────────────────────────

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({required this.model, required Listenable repaint})
    : super(repaint: repaint);

  final _NetworkModel model;

  // Reused across every frame and every element.
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _nodePaint = Paint()..isAntiAlias = true;
  final Paint _haloPaint = Paint()..isAntiAlias = true;
  final Paint _pulsePaint = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final m = model;
    if (size.isEmpty) return;
    // Guarded: rebuilds the composition only when the viewport changed.
    if (m.size != size) m.layout(size);
    if (m.nodes.isEmpty) return;

    m.updateFrame();
    _paintAtmosphere(canvas, m);
    _paintArcs(canvas, m);
    _paintConnections(canvas, m);
    _paintNodes(canvas, m);
    if (!m.reducedMotion) _paintPulses(canvas, m);
  }

  void _paintAtmosphere(Canvas canvas, _NetworkModel m) {
    if (m.atmosphere.isEmpty) return;
    final px = m.parallaxX;
    final py = m.parallaxY;
    for (final field in m.atmosphere) {
      // save/restore is cheap — this is a transform, not a saveLayer.
      canvas.save();
      canvas.translate(px * field.depth, py * field.depth);
      canvas.drawRect(field.rect, field.paint);
      canvas.restore();
    }
  }

  void _paintArcs(Canvas canvas, _NetworkModel m) {
    if (m.arcs.isEmpty) return;
    _arcPaint.strokeWidth = m.config.arcWidth;
    final px = m.parallaxX;
    final py = m.parallaxY;
    for (final arc in m.arcs) {
      _arcPaint.color = m._rampColor(m._arcRamp, arc.opacity);
      canvas.save();
      canvas.translate(px * arc.depth, py * arc.depth);
      canvas.drawPath(arc.path, _arcPaint);
      canvas.restore();
    }
  }

  void _paintConnections(Canvas canvas, _NetworkModel m) {
    m.buildLineBatches();
    _linePaint.strokeWidth = m.config.lineWidth;

    final tiers = m.config.lineTierCount;
    for (var tier = 0; tier < tiers; tier++) {
      final count = m._lineCounts[tier];
      if (count == 0) continue;
      // Representative alpha per tier — at these very low opacities the
      // quantisation is imperceptible, and it collapses hundreds of draw
      // calls into `lineTierCount`.
      _linePaint.color = m._rampColor(m._lineRamp, (tier + 0.5) / tiers);
      canvas.drawRawPoints(
        ui.PointMode.lines,
        Float32List.sublistView(m._lineBuffers[tier], 0, count * 4),
        _linePaint,
      );
    }
  }

  void _paintNodes(Canvas canvas, _NetworkModel m) {
    final boost = m.config.activationNodeBoost;
    final hubHalo = m.config.hubHaloOpacity;

    for (var i = 0; i < m.nodes.length; i++) {
      final n = m.nodes[i];
      final centre = Offset(n.x, n.y);
      final activation = n.activation;

      // Permanent faint disc gives hubs presence without any blur filter.
      if (n.tier == _NodeTier.hub && hubHalo > 0) {
        _haloPaint.color = m._rampColor(m._haloRamp, hubHalo * n.depth);
        canvas.drawCircle(centre, n.radius * 3.2, _haloPaint);
      }

      // Activation halo: two low-alpha discs read as a soft glow, again with
      // no MaskFilter/saveLayer cost.
      if (activation > 0.04) {
        _haloPaint.color = m._rampColor(m._haloRamp, activation * 0.55);
        canvas.drawCircle(centre, n.radius + 5 + activation * 5, _haloPaint);
        _haloPaint.color = m._rampColor(m._haloRamp, activation);
        canvas.drawCircle(centre, n.radius + 2 + activation * 2.5, _haloPaint);
      }

      final alpha = (n.opacity + activation * boost).clamp(0.0, 1.0);
      _nodePaint.color = m._rampColor(m._nodeRamp, alpha);
      canvas.drawCircle(centre, n.radius, _nodePaint);
    }
  }

  void _paintPulses(Canvas canvas, _NetworkModel m) {
    for (final pulse in m.pulses) {
      if (!pulse.active) continue;
      final conn = m.connections[pulse.route[pulse.hop]];
      final fromIndex = pulse.from[pulse.hop];
      final from = m.nodes[fromIndex];
      final to = m.nodes[conn.a == fromIndex ? conn.b : conn.a];

      final p = pulse.progress;
      // Fade across the whole route, not per hop, so multi-hop travel reads
      // as one continuous packet.
      final routeT = (pulse.hop + p) / pulse.hops;
      final fade = math.sin(routeT.clamp(0.0, 1.0) * math.pi);
      if (fade <= 0.02) continue;

      final centre = Offset(
        from.x + (to.x - from.x) * p,
        from.y + (to.y - from.y) * p,
      );
      _pulsePaint.color = m._rampColor(m._pulseRamp, fade * 0.45);
      canvas.drawCircle(centre, m.config.pulseRadius * 2.4, _pulsePaint);
      _pulsePaint.color = m._rampColor(m._pulseRamp, fade);
      canvas.drawCircle(centre, m.config.pulseRadius, _pulsePaint);
    }
  }

  // Repaints are driven entirely by the `repaint` listenable, so this only
  // matters when the widget rebuilds with a genuinely different painter.
  @override
  bool shouldRepaint(_NetworkPainter oldDelegate) => oldDelegate.model != model;

  @override
  bool shouldRebuildSemantics(_NetworkPainter oldDelegate) => false;
}

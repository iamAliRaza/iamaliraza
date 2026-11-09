import 'package:flutter/foundation.dart';

/// Every tunable of the ambient "living architecture" background, in one
/// place. This layer is decorative chrome behind the portfolio, so the safe
/// direction to tune anything here is *down*.
///
/// Opacity/strength values are 0..1 fractions. Distances are logical pixels
/// unless the name ends in `Factor` (fraction of viewport width) .
@immutable
class ArchitectureBackgroundConfig {
  const ArchitectureBackgroundConfig({
    this.desktopNodeCount = 94,
    this.tabletNodeCount = 62,
    this.mobileNodeCount = 34,
    this.clusterBudgetFraction = 0.82,
    this.ambientNodeFraction = 0.54,
    this.activeNodeFraction = 0.33,
    this.ambientRadiusMin = 0.7,
    this.ambientRadiusMax = 1.3,
    this.activeRadiusMin = 1.5,
    this.activeRadiusMax = 2.3,
    this.hubRadiusMin = 2.9,
    this.hubRadiusMax = 4.3,
    this.nodeOpacity = 0.52,
    this.hubHaloOpacity = 0.10,
    this.intraClusterLinks = 3,
    this.intraClusterDistanceFactor = 0.13,
    this.interClusterLinks = 2,
    this.longLinkEndFadeRatio = 0.20,
    this.lineOpacity = 0.17,
    this.lineWidth = 0.65,
    this.lineTierCount = 5,
    this.arcCount = 5,
    this.arcOpacity = 0.070,
    this.arcWidth = 0.8,
    this.arcBowFactor = 0.22,
    this.atmosphereCount = 4,
    this.atmosphereOpacity = 0.030,
    this.atmosphereRadiusFactor = 0.42,
    this.clusterDriftAmplitude = 13,
    this.clusterDriftSpeed = 0.030,
    this.nodeDriftAmplitude = 4.5,
    this.nodeDriftSpeed = 0.055,
    this.connectionBreatheSpeed = 0.06,
    this.activationPeriodMin = 15,
    this.activationPeriodMax = 30,
    this.activationDutyCycle = 0.09,
    this.activationNodeBoost = 0.48,
    this.activationHaloOpacity = 0.16,
    this.activationLineBoost = 0.20,
    this.pulseIntervalSeconds = 2.2,
    this.mobilePulseIntervalMultiplier = 2.0,
    this.pulseSpeed = 0.42,
    this.maxConcurrentPulses = 4,
    this.maxPulseHops = 3,
    this.pulseRadius = 1.8,
    this.pulseOpacity = 0.60,
    this.parallaxStrength = 15,
    this.parallaxEasing = 2.4,
    this.depthMin = 0.22,
    this.depthMax = 1.0,
    this.textAreaDimming = 0.42,
    this.alphaSteps = 28,
    this.respectReducedMotion = true,
    this.seed = 0x5EED,
  });

  // ── Density per breakpoint ─────────────────────────────────────────────
  final int desktopNodeCount;
  final int tabletNodeCount;
  final int mobileNodeCount;

  // ── Node tiers ─────────────────────────────────────────────────────────
  /// Share of the node budget placed inside clusters. The remainder is
  /// scattered thinly across the whole viewport as ambient dust, which both
  /// guarantees the budget is actually met (cluster placement can reject
  /// candidates) and supplies the low-density areas between clusters.
  final double clusterBudgetFraction;

  /// Share of nodes that are tiny ambient points; then small "active" nodes.
  /// Whatever remains becomes a larger architectural hub node.
  final double ambientNodeFraction;
  final double activeNodeFraction;

  final double ambientRadiusMin;
  final double ambientRadiusMax;
  final double activeRadiusMin;
  final double activeRadiusMax;
  final double hubRadiusMin;
  final double hubRadiusMax;

  final double nodeOpacity;

  /// Permanent faint disc behind hub nodes, giving them presence without blur.
  final double hubHaloOpacity;

  // ── Connections ────────────────────────────────────────────────────────
  /// Nearest-N edges kept per node inside its own cluster.
  final int intraClusterLinks;

  /// Max intra-cluster edge length, as a fraction of viewport width.
  final double intraClusterDistanceFactor;

  /// Long structural edges wired between each pair of neighbouring clusters.
  final int interClusterLinks;

  /// Long edges are emitted as three segments so their ends read dimmer than
  /// their middle — an end-fade look with no per-line gradient shader.
  final double longLinkEndFadeRatio;

  final double lineOpacity;
  final double lineWidth;

  /// Connections are bucketed into this many opacity tiers, so each tier is
  /// one batched draw call instead of one call per line.
  final int lineTierCount;

  // ── Large architectural arcs ───────────────────────────────────────────
  final int arcCount;
  final double arcOpacity;
  final double arcWidth;

  /// How far an arc bows away from the straight line between its endpoints.
  final double arcBowFactor;

  // ── Atmospheric light fields ───────────────────────────────────────────
  /// Very soft, very low-opacity grayscale radial fields that stop the black
  /// from reading as flat. Static geometry, precomputed shaders.
  final int atmosphereCount;
  final double atmosphereOpacity;
  final double atmosphereRadiusFactor;

  // ── Movement ───────────────────────────────────────────────────────────
  /// Whole clusters drift together (the dominant motion), while each node
  /// adds only a small independent wobble on top. That ratio is what keeps
  /// this reading as a coordinated system rather than a particle field.
  final double clusterDriftAmplitude;
  final double clusterDriftSpeed;
  final double nodeDriftAmplitude;
  final double nodeDriftSpeed;
  final double connectionBreatheSpeed;

  // ── Node activation ────────────────────────────────────────────────────
  final double activationPeriodMin;
  final double activationPeriodMax;

  /// Fraction of each node's cycle spent lit. At 0.09, ~91% of nodes are
  /// dormant at any instant — that ratio keeps the layer calm and cheap.
  final double activationDutyCycle;
  final double activationNodeBoost;
  final double activationHaloOpacity;
  final double activationLineBoost;

  // ── Data-flow pulses ───────────────────────────────────────────────────
  final double pulseIntervalSeconds;
  final double mobilePulseIntervalMultiplier;

  /// Fraction of one connection traversed per second.
  final double pulseSpeed;
  final int maxConcurrentPulses;

  /// A pulse may continue through this many connected edges before fading.
  final int maxPulseHops;
  final double pulseRadius;
  final double pulseOpacity;

  // ── Pointer parallax (desktop only) ────────────────────────────────────
  final double parallaxStrength;
  final double parallaxEasing;

  // ── Depth ──────────────────────────────────────────────────────────────
  /// Depth drives parallax amount, brightness and size jitter together.
  final double depthMin;
  final double depthMax;

  /// Nodes landing behind the hero copy are dimmed by this factor so the
  /// text stays comfortably readable.
  final double textAreaDimming;

  // ── Rendering internals ────────────────────────────────────────────────
  /// Size of the precomputed alpha ramps, so painting never allocates a
  /// `Color` per node per frame.
  final int alphaSteps;

  // ── Accessibility ──────────────────────────────────────────────────────
  /// When true and the platform reports reduced motion, the layer renders
  /// statically and the ticker is stopped outright.
  final bool respectReducedMotion;

  /// Fixed seed keeps the generated composition deterministic across builds.
  final int seed;
}

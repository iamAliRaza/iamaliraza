import 'package:flutter/material.dart';

/// Wraps [builder] in a [MouseRegion] and rebuilds it with the current hover
/// state — the shared mechanism behind every widget that mirrors a Figma
/// "Default"/hover variant pair (buttons, chips, cards, skill badges).
class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final MouseCursor cursor;

  const HoverBuilder({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.basic,
  });

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (_isHovered != value) setState(() => _isHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: widget.builder(context, _isHovered),
    );
  }
}

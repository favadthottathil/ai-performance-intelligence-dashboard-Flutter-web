import 'package:flutter/material.dart';

/// A small status pill showing whether the dashboard's live metrics stream
/// is currently connected.
///
/// When connected it pulses and reads "Live"; when not, it settles into a
/// static "Polling" state. It never claims to be live on data that is only
/// being refreshed on a timer.
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key, required this.isLive});

  /// Whether the live metrics stream is currently connected.
  final bool isLive;

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  static const _liveColor = Color(0xFF10B981);
  static const _idleColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Built once rather than allocated per frame inside build().
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

    if (widget.isLive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(LiveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive == oldWidget.isLive) return;

    // Leaving the controller spinning while disconnected would burn frames
    // animating a dot that no longer means anything.
    if (widget.isLive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.isLive;
    final color = isLive ? _liveColor : _idleColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isLive ? 'Live' : 'Polling',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

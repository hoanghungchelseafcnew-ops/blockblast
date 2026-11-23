import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Confetti bay từ dưới lên một lần rồi dừng (FR6.1, interaction-spec:
/// hiệu ứng chính 2–3 giây). Màn Victory không dựng widget này khi người dùng
/// bật giảm chuyển động.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({
    super.key,
    required this.colors,
    this.duration = defaultDuration,
    this.count = 40,
    this.seed = 7,
  });

  static const Duration defaultDuration = Duration(milliseconds: 2500);

  final List<Color> colors;
  final Duration duration;
  final int count;

  /// Hạt giống ngẫu nhiên cố định để hình ảnh ổn định giữa các lần dựng.
  final int seed;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.seed);
    _pieces = List<_Piece>.generate(widget.count, (i) {
      return _Piece(
        x: random.nextDouble(),
        drift: (random.nextDouble() - 0.5) * 0.3,
        delay: random.nextDouble() * 0.3,
        size: 4 + random.nextDouble() * 6,
        spin: random.nextDouble() * math.pi * 4,
        color: widget.colors[i % widget.colors.length],
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _done = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          key: const Key('confetti-paint'),
          painter: _ConfettiPainter(_controller, _pieces),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.drift,
    required this.delay,
    required this.size,
    required this.spin,
    required this.color,
  });

  final double x;
  final double drift;
  final double delay;
  final double size;
  final double spin;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation, this.pieces) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint();
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeOut.transform(local);
      final dx = (p.x + p.drift * eased) * size.width;
      final dy = size.height * (1 - eased * 1.1);
      paint.color = p.color.withValues(alpha: 1 - local * 0.8);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * eased);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size / 2),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}

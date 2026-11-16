import 'dart:math';
import 'package:flutter/material.dart';

class ParticleExplosion extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;

  const ParticleExplosion({
    super.key,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Generate particles
    for (int i = 0; i < 8; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double speed = random.nextDouble() * 30 + 10;
      particles.add(Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: random.nextDouble() * 6 + 4,
      ));
    }

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        particles: particles,
        progress: _controller.value,
        color: widget.color,
      ),
    );
  }
}

class Particle {
  final double dx;
  final double dy;
  final double size;

  Particle({required this.dx, required this.dy, required this.size});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      double curX = size.width / 2 + (p.dx * progress * 2);
      double curY = size.height / 2 + (p.dy * progress * 2);
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(curX, curY),
          width: p.size * (1 - progress * 0.5),
          height: p.size * (1 - progress * 0.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

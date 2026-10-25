import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  double x;
  double y;
  double opacity;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.x,
    required this.y,
    this.opacity = 1.0,
  });
}

class ParticleExplosionWidget extends StatefulWidget {
  final bool trigger;
  final VoidCallback? onComplete;

  const ParticleExplosionWidget({
    super.key,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<ParticleExplosionWidget> createState() => _ParticleExplosionWidgetState();
}

class _ParticleExplosionWidgetState extends State<ParticleExplosionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.trigger) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant ParticleExplosionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _generateParticles();
      _controller.forward(from: 0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 150;
      final size = 2 + _random.nextDouble() * 6;
      final color = Color.lerp(
        const Color(0xFF4A90E2),
        const Color(0xFF7B68EE),
        _random.nextDouble(),
      )!;

      _particles.add(Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: color,
        x: 0,
        y: 0,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: t,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + cos(particle.angle) * distance;
      final y = center.dy + sin(particle.angle) * distance;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
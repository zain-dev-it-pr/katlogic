import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  final List<_Star> _stars = [];
  final int starCount = 40;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _generateStars();
  }

  void _generateStars() {
    final random = Random();

    for (int i = 0; i < starCount; i++) {
      _stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2 + 1,
          twinkleOffset: random.nextDouble() * 2 * pi,
          speed: random.nextDouble() * 0.0008 + 0.0002,
        ),
      );
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
        final value = _controller.value;

        return Stack(
          children: [

            /// 🌌 Smooth Elegant Gradient
            Container(
              decoration: BoxDecoration(
                : LinearGradient(
                  begin: Alignment(
                    sin(value * 2 * pi),
                    cos(value * 2 * pi),
                  ),
                  end: Alignment(
                    -sin(value * 2 * pi),
                    -cos(value * 2 * pi),
                  ),
                  colors: const [
                    Color(0xFF000814),
                    Color(0xFF001D3D),
                    Color(0xFF003566),
                    Color(0xFF000814),
                  ],
                ),
              ),
            ),

            /// ✨ Sparkling Stars
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _StarPainter(_stars, value),
            ),

            widget.child,
          ],
        );
      },
    );
  }
}

class _Star {
  double x;
  double y;
  double size;
  double twinkleOffset;
  double speed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
    required this.speed,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animationValue;

  _StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {

      // Twinkle effect using sine wave
      double brightness =
          (sin(animationValue * 2 * pi + star.twinkleOffset) + 1) / 2;

      final dx = star.x * size.width;
      final dy = ((star.y - animationValue * star.speed * 100) % 1.0) *
          size.height;

      /// Soft glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.25 * brightness)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(
        Offset(dx, dy),
        star.size * 2.5,
        glowPaint,
      );

      /// Bright core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(0.9 * brightness);

      canvas.drawCircle(
        Offset(dx, dy),
        star.size,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

class BackgroundPaint extends StatelessWidget {
  const BackgroundPaint({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _BackgroundPainter());
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.deepPurple.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Dessine des cercles aléatoires
    for (int i = 0; i < 30; i++) {
      final x = (size.width * (i / 20)) + 5;
      final y = size.height * ((i % 6) / 5) + 10;
      canvas.drawCircle(Offset(x, y), 30, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

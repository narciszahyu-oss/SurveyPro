import 'package:flutter/material.dart';

class MathSheetBackground extends StatelessWidget {
  final Widget child;
  const MathSheetBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _MathSheetPainter(),
      // 👇 force full size of parent
      child: SizedBox.expand(
        child: child,
      ),
    );
  }
}

class _MathSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Debug background to confirm paint area
    final bg = Paint()..color = Colors.black12;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    const double step = 20;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';

// ── Circle People Painter (Join a Circle hero card) ──
class CirclePeoplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    final personPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    const numberOfPeople = 8;
    for (int i = 0; i < numberOfPeople; i++) {
      final angle = (2 * pi * i) / numberOfPeople;
      final x = center.dx + radius * 0.9 * cos(angle);
      final y = center.dy + radius * 0.9 * sin(angle);

      canvas.drawCircle(Offset(x, y), 6, personPaint);

      final lineEndX = center.dx + radius * cos(angle);
      final lineEndY = center.dy + radius * sin(angle);
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, y), Offset(lineEndX, lineEndY), linePaint);
    }

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Prayer Beads Icon (Recite card) ──
class PrayerBeadsIcon extends StatelessWidget {
  const PrayerBeadsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(50, 60), painter: PrayerBeadsPainter());
  }
}

class PrayerBeadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final beadPaint = Paint()
      ..color = const Color(0xFFD4A574)
      ..style = PaintingStyle.fill;

    final stringPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.8,
        size.width * 0.8, size.height * 0.1,
      );
    canvas.drawPath(path, stringPaint);

    final beadPositions = [
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.35, size.height * 0.55),
      Offset(size.width * 0.42, size.height * 0.68),
      Offset(size.width * 0.5, size.height * 0.75),
      Offset(size.width * 0.58, size.height * 0.68),
      Offset(size.width * 0.65, size.height * 0.55),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.1),
    ];

    for (final position in beadPositions) {
      canvas.drawCircle(position, 5, beadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Checklist Icon (Retain card) ──
class ChecklistIcon extends StatelessWidget {
  const ChecklistIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(50, 60), painter: ChecklistPainter());
  }
}

class ChecklistPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF2D9E7D)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2;

    final checkPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 10, size.width - 10, size.height - 15),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, bgPaint);

    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, 5, size.width * 0.3, 12),
      const Radius.circular(4),
    );
    canvas.drawRRect(clipRect, Paint()..color = const Color(0xFF1A7A5E));

    for (int i = 0; i < 3; i++) {
      final y = 25 + i * 12;
      canvas.drawRect(
        Rect.fromLTWH(12, y.toDouble(), 8, 8),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
      canvas.drawLine(
        Offset(25, y + 4),
        Offset(size.width - 12, y + 4),
        linePaint,
      );
    }

    final checkPath = Path()
      ..moveTo(13, 29)
      ..lineTo(15, 32)
      ..lineTo(19, 26);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Circular Progress Icon (Track card) ──
class CircularProgressIcon extends StatelessWidget {
  const CircularProgressIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: CircularProgressPainter(),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final colors = [
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
      const Color(0xFF15803D),
      const Color(0xFF166534),
    ];

    const segments = 12;
    const gap = 0.15;
    const segmentAngle = (2 * pi) / segments;

    for (int i = 0; i < 8; i++) {
      final startAngle = -pi / 2 + i * segmentAngle + gap / 2;
      final sweepAngle = segmentAngle - gap;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

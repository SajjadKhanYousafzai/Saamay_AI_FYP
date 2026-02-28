import 'dart:math';
import 'package:flutter/material.dart';

class SaamayAIApp extends StatelessWidget {
  const SaamayAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SaamayAIHomeScreen(),
    );
  }
}

class SaamayAIHomeScreen extends StatefulWidget {
  const SaamayAIHomeScreen({super.key});

  @override
  State<SaamayAIHomeScreen> createState() => _SaamayAIHomeScreenState();
}

class _SaamayAIHomeScreenState extends State<SaamayAIHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1729),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Saamay AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D9E7D), Color(0xFF1A7A5E)],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'إنضم لحلقة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1A7A5E),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Join a Circle',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circle illustration
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(painter: CirclePeoplePainter()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Feature Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildFeatureCard(
                  title: 'Memorize',
                  subtitle: 'Learn verses',
                  icon: Icons.menu_book,
                  gradientColors: const [Color(0xFF2D5A3D), Color(0xFF1E3D2A)],
                  iconColor: const Color(0xFF4ADE80),
                ),
                _buildFeatureCard(
                  title: 'Recite',
                  subtitle: 'Read aloud',
                  iconWidget: const PrayerBeadsIcon(),
                  gradientColors: const [Color(0xFF4A3B5C), Color(0xFF2D1F3D)],
                ),
                _buildFeatureCard(
                  title: 'Retain',
                  subtitle: 'Practice recall',
                  iconWidget: const ChecklistIcon(),
                  gradientColors: const [Color(0xFF5C4033), Color(0xFF3D2B1F)],
                ),
                _buildFeatureCard(
                  title: 'Track',
                  subtitle: 'View progress',
                  iconWidget: const CircularProgressIcon(),
                  gradientColors: const [Color(0xFF2A3A4A), Color(0xFF1A2A3A)],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: const Color(0xFF1A2332),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4ADE80),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline),
                label: 'Memorize',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Recite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.hearing),
                label: 'Retain',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Track',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    IconData? icon,
    Widget? iconWidget,
    required List<Color> gradientColors,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            if (icon != null)
              Icon(
                icon,
                size: 50,
                color: iconColor ?? Colors.white.withOpacity(0.8),
              ),
            if (iconWidget != null) iconWidget,
          ],
        ),
      ),
    );
  }
}

// Custom painter for circle of people illustration
class CirclePeoplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw circle outline
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw people dots around the circle
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final personPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    const numberOfPeople = 8;
    for (int i = 0; i < numberOfPeople; i++) {
      final angle = (2 * 3.14159 * i) / numberOfPeople;
      final x = center.dx + radius * 0.9 * cos(angle);
      final y = center.dy + radius * 0.9 * sin(angle);

      // Draw person as small circle
      canvas.drawCircle(Offset(x, y), 6, personPaint);

      // Draw connection line
      final lineEndX = center.dx + radius * cos(angle);
      final lineEndY = center.dy + radius * sin(angle);
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, y), Offset(lineEndX, lineEndY), linePaint);
    }

    // Center dot
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Prayer beads icon widget
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

    // Draw curved string
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.8,
        size.width * 0.8,
        size.height * 0.1,
      );
    canvas.drawPath(path, stringPaint);

    // Draw beads along the curve
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
  bool shouldRepaint(covariant CustomPainter) => false;
}

// Checklist icon widget
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
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2;

    final checkPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw clipboard background
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 10, size.width - 10, size.height - 15),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, bgPaint);

    // Draw clip at top
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, 5, size.width * 0.3, 12),
      const Radius.circular(4),
    );
    canvas.drawRRect(clipRect, Paint()..color = const Color(0xFF1A7A5E));

    // Draw checklist lines
    for (int i = 0; i < 3; i++) {
      final y = 25 + i * 12;
      // Checkbox
      canvas.drawRect(
        Rect.fromLTWH(12, y.toDouble(), 8, 8),
        Paint()..color = Colors.white.withOpacity(0.3),
      );
      // Line
      canvas.drawLine(
        Offset(25, y + 4),
        Offset(size.width - 12, y + 4),
        linePaint,
      );
    }

    // Draw checkmark on first item
    final checkPath = Path()
      ..moveTo(13, 29)
      ..lineTo(15, 32)
      ..lineTo(19, 26);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Circular progress icon widget
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

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arcs with different colors
    final colors = [
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
      const Color(0xFF15803D),
      const Color(0xFF166534),
    ];

    const segments = 12;
    const gap = 0.15;
    const segmentAngle = (2 * 3.14159) / segments;

    for (int i = 0; i < 8; i++) {
      final startAngle = -3.14159 / 2 + i * segmentAngle + gap / 2;
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

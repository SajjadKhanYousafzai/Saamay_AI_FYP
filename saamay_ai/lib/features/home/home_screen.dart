import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index) onFeatureTap;

  const HomeScreen({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero Card with wave animation
          const _HeroCard(),
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
              _BouncingFeatureCard(
                title: 'Memorize',
                subtitle: 'Learn verses',
                imageAsset: 'assets/images/book.png',
                gradientColors: const [Color(0xFF2D5A3D), Color(0xFF1E3D2A)],
                onTap: () => onFeatureTap(1),
              ),
              _BouncingFeatureCard(
                title: 'Recite',
                subtitle: 'Read aloud',
                imageAsset: 'assets/images/tasbih.png',
                gradientColors: const [Color(0xFF4A3B5C), Color(0xFF2D1F3D)],
                onTap: () => onFeatureTap(2),
              ),
              _BouncingFeatureCard(
                title: 'Retain',
                subtitle: 'Practice recall',
                imageAsset: 'assets/images/clipboard.png',
                gradientColors: const [Color(0xFF5C4033), Color(0xFF3D2B1F)],
                onTap: () => onFeatureTap(3),
              ),
              _BouncingFeatureCard(
                title: 'Track',
                subtitle: 'View progress',
                imageAsset: 'assets/images/progress.png',
                gradientColors: const [Color(0xFF2A3A4A), Color(0xFF1A2A3A)],
                onTap: () => onFeatureTap(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card with animated waves, sparkles, and floating image ───
class _HeroCard extends StatefulWidget {
  const _HeroCard();

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation — long duration for seamless continuous flow
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Sparkle twinkling
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _sparkleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3BAF8A), Color(0xFF2D9E7D), Color(0xFF1A7A5E)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Animated waves
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 190),
                  painter: _WavePainter(
                    animationValue: _waveController.value,
                  ),
                );
              },
            ),

            // Sparkle stars
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, _) {
                return Stack(
                  children: [
                    _buildSparkle(right: 80, top: 20, size: 8,
                        opacity: _sparkleAnimation.value),
                    _buildSparkle(right: 140, top: 45, size: 6,
                        opacity: 1.0 - _sparkleAnimation.value * 0.5),
                    _buildSparkle(right: 50, top: 55, size: 10,
                        opacity: _sparkleAnimation.value * 0.8),
                  ],
                );
              },
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
                        Text(
                          'إنضم لحلقة',
                          style: GoogleFonts.amiriQuran(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.white.withOpacity(0.9),
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
                          child: const FittedBox(
                            child: Row(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Circle illustration (static)
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Image.asset(
                      'assets/images/circle.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkle({
    required double right,
    required double top,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      right: right,
      top: top,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Icon(
          Icons.star,
          size: size,
          color: const Color(0xFFFFD700),
        ),
      ),
    );
  }
}

// Wave painter for the hero card
class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Wave 1 — lighter, slopes up to the right
    final wave1Paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final wave1Path = Path();
    wave1Path.moveTo(0, size.height);
    wave1Path.lineTo(0, size.height * 0.75);
    for (double x = 0; x <= size.width; x++) {
      // Slope: left starts at 0.75, right ends at 0.45 (higher)
      final slope = 0.75 - (x / size.width) * 0.30;
      final y = size.height * slope +
          sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * 10 +
          sin((x / size.width * 4 * pi) + (animationValue * 4 * pi)) * 5;
      wave1Path.lineTo(x, y);
    }
    wave1Path.lineTo(size.width, size.height);
    wave1Path.close();
    canvas.drawPath(wave1Path, wave1Paint);

    // Wave 2 — slightly darker, also slopes up
    final wave2Paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);
    wave2Path.lineTo(0, size.height * 0.80);
    for (double x = 0; x <= size.width; x++) {
      // Slope: left starts at 0.80, right ends at 0.55
      final slope = 0.80 - (x / size.width) * 0.25;
      final y = size.height * slope +
          sin((x / size.width * 2 * pi) +
                  (animationValue * 2 * pi) +
                  pi * 0.8) *
              8 +
          sin((x / size.width * 3 * pi) +
                  (animationValue * 2 * pi)) *
              4;
      wave2Path.lineTo(x, y);
    }
    wave2Path.lineTo(size.width, size.height);
    wave2Path.close();
    canvas.drawPath(wave2Path, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Animated bouncing feature card
class _BouncingFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _BouncingFeatureCard({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.gradientColors,
    this.onTap,
  });

  @override
  State<_BouncingFeatureCard> createState() => _BouncingFeatureCardState();
}

class _BouncingFeatureCardState extends State<_BouncingFeatureCard>
    with TickerProviderStateMixin {
  // Tap scale animation
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  // Card entrance animation
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;



  @override
  void initState() {
    super.initState();

    // Tap scale
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // Card entrance — rises from below
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _slideAnimation = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.bounceOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );



    // Start card entrance with delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    _entranceController.dispose();

    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _entranceController]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

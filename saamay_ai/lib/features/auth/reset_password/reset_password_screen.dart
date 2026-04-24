import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  // Animations
  late AnimationController _waveController;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  late AnimationController _formController;
  late Animation<double> _formSlide;
  late Animation<double> _formOpacity;
  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _sparkleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _sparkleController.repeat(reverse: true);

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _formSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _sparkleController.dispose();
    _formController.dispose();
    _successController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() => _emailSent = true);
      _successController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // ── Background waves ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AuthWavePainter(
                    animationValue: _waveController.value,
                    primary: primary,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // ── Sparkle stars ──
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, _) {
              return Stack(
                children: [
                  _sparkle(60, 90, 8, _sparkleAnimation.value, primary),
                  _sparkle(250, 70, 6, 1.0 - _sparkleAnimation.value * 0.5, primary),
                  _sparkle(160, 130, 10, _sparkleAnimation.value * 0.8, primary),
                  _sparkle(320, 150, 5, _sparkleAnimation.value * 0.6, primary),
                ],
              );
            },
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                // ── Back button ──
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // ── Scrollable form ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _formController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _formOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _formSlide.value),
                            child: child,
                          ),
                        );
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // ── Book logo ──
                            Container(
                              width: 80,
                              height: 80,
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/book.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Title ──
                            Text(
                              AppStrings.resetPassword,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textDark,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your email to receive a\npassword reset link',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                            ),
                            const SizedBox(height: 36),

                            // ── Success card (animated) ──
                            if (_emailSent)
                              AnimatedBuilder(
                                animation: _successScale,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _successScale.value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.success.withOpacity(0.08)
                                        : AppColors.success.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.success.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.success.withOpacity(0.15),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: AppColors.success,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Reset Link Sent!',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppColors.textDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Check your email for the password reset link.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : AppColors.textGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // ── Error message ──
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.error, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                            color: AppColors.error, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Email form card ──
                            if (!_emailSent)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : primary.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(isDark ? 0.3 : 0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _emailController,
                                      hintText: AppStrings.email,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    CustomButton(
                                      text: AppStrings.sendResetLink,
                                      onPressed: _resetPassword,
                                      isLoading: _isLoading,
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 28),

                            // ── Back to login ──
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, size: 16, color: primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sparkle(double left, double top, double size, double opacity, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Icon(Icons.auto_awesome, size: size, color: color.withOpacity(0.6)),
      ),
    );
  }
}

/// Background wave painter for auth screens
class _AuthWavePainter extends CustomPainter {
  final double animationValue;
  final Color primary;
  final bool isDark;

  _AuthWavePainter({
    required this.animationValue,
    required this.primary,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Top gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primary.withOpacity(isDark ? 0.15 : 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.45), gradientPaint);

    // Wave 1
    final wave1Paint = Paint()
      ..color = primary.withOpacity(isDark ? 0.06 : 0.04)
      ..style = PaintingStyle.fill;

    final wave1 = Path();
    wave1.moveTo(0, size.height * 0.22);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.22 +
          sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * 18 +
          sin((x / size.width * 4 * pi) + (animationValue * 4 * pi)) * 7;
      wave1.lineTo(x, y);
    }
    wave1.lineTo(size.width, 0);
    wave1.lineTo(0, 0);
    wave1.close();
    canvas.drawPath(wave1, wave1Paint);

    // Wave 2 (bottom)
    final wave2Paint = Paint()
      ..color = primary.withOpacity(isDark ? 0.04 : 0.025)
      ..style = PaintingStyle.fill;

    final wave2 = Path();
    wave2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.88 +
          sin((x / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * 14 +
          sin((x / size.width * 3 * pi) + (animationValue * 3 * pi)) * 5;
      wave2.lineTo(x, y);
    }
    wave2.lineTo(size.width, size.height);
    wave2.close();
    canvas.drawPath(wave2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant _AuthWavePainter old) =>
      old.animationValue != animationValue;
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../config/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Animations
  late AnimationController _waveController;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  late AnimationController _formController;
  late Animation<double> _formSlide;
  late Animation<double> _formOpacity;

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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _sparkleController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
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
                  _sparkle(50, 80, 8, _sparkleAnimation.value, primary),
                  _sparkle(120, 120, 6, 1.0 - _sparkleAnimation.value * 0.5, primary),
                  _sparkle(280, 60, 10, _sparkleAnimation.value * 0.8, primary),
                  _sparkle(200, 140, 5, _sparkleAnimation.value * 0.6, primary),
                ],
              );
            },
          ),

          // ── Main content ──
          SafeArea(
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
                      const SizedBox(height: 70),

                      // ── Book logo with glow ──
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/book.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Title ──
                      Text(
                        'Saamay AI',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGrey,
                            ),
                      ),
                      const SizedBox(height: 36),

                      // ── Glassmorphism form card ──
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
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Error message
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

                            // Email field
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
                            const SizedBox(height: 16),

                            // Password field
                            CustomTextField(
                              controller: _passwordController,
                              hintText: AppStrings.password,
                              obscureText: _obscurePassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.resetPassword),
                                child: Text(
                                  AppStrings.forgotPassword,
                                  style: TextStyle(color: primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Login button
                            CustomButton(
                              text: AppStrings.login,
                              onPressed: _login,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.textGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.signUp),
                            child: Text(
                              AppStrings.signUp,
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
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
        stops: const [0.0, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5), gradientPaint);

    // Wave 1
    final wave1Paint = Paint()
      ..color = primary.withOpacity(isDark ? 0.06 : 0.04)
      ..style = PaintingStyle.fill;

    final wave1 = Path();
    wave1.moveTo(0, size.height * 0.25);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.25 +
          sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * 20 +
          sin((x / size.width * 4 * pi) + (animationValue * 4 * pi)) * 8;
      wave1.lineTo(x, y);
    }
    wave1.lineTo(size.width, 0);
    wave1.lineTo(0, 0);
    wave1.close();
    canvas.drawPath(wave1, wave1Paint);

    // Wave 2
    final wave2Paint = Paint()
      ..color = primary.withOpacity(isDark ? 0.04 : 0.025)
      ..style = PaintingStyle.fill;

    final wave2 = Path();
    wave2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.85 +
          sin((x / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * 15 +
          sin((x / size.width * 3 * pi) + (animationValue * 3 * pi)) * 6;
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'retain_provider.dart';

class RetainScreen extends StatelessWidget {
  const RetainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RetainProvider()..loadMemorizedVerses(),
      child: const _RetainView(),
    );
  }
}

class _RetainView extends StatelessWidget {
  const _RetainView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RetainProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ──
          Row(
            children: [
              _statCard(
                context,
                label: 'Correct',
                value: '${provider.correctCount}',
                color: AppColors.success,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _statCard(
                context,
                label: 'Incorrect',
                value: '${provider.incorrectCount}',
                color: AppColors.error,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _statCard(
                context,
                label: 'Rate',
                value: '${provider.successRate.toStringAsFixed(0)}%',
                color: Theme.of(context).colorScheme.primary,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Quiz Card ──
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              ),
            )
          else if (provider.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                provider.error!,
                style: const TextStyle(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
            )
          else if (provider.currentQuizVerse != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.retainGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Surah : Ayah badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Surah ${provider.currentQuizVerse!['surah']} : Ayah ${provider.currentQuizVerse!['ayah']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Prompt
                  Text(
                    provider.isVerseRevealed
                        ? 'Did you recall it correctly?'
                        : 'Can you recall this verse?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verse (hidden or revealed)
                  AnimatedCrossFade(
                    firstChild: Container(
                      width: double.infinity,
                      height: 100,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Reveal" when ready',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: Column(
                      children: [
                        Text(
                          provider.currentQuizVerse!['text'] ?? '',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiriQuran(
                            color: Colors.white,
                            fontSize: 26,
                            height: 2.0,
                          ),
                        ),
                        if (provider.currentQuizVerse!['translation_en'] !=
                            null) ...[
                          const SizedBox(height: 12),
                          Text(
                            provider.currentQuizVerse!['translation_en'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    crossFadeState: provider.isVerseRevealed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Action Buttons ──
            if (!provider.isVerseRevealed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.revealVerse,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Reveal Verse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.markIncorrect,
                      icon: const Icon(Icons.close),
                      label: const Text('Incorrect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.2),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.markCorrect,
                      icon: const Icon(Icons.check),
                      label: const Text('Correct'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textGrey : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

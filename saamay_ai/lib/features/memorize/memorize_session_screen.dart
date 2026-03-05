import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'memorize_provider.dart';

class MemorizeSessionScreen extends StatelessWidget {
  const MemorizeSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemorizeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final surah = provider.selectedSurah;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back, color: primary, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${surah.name} Memorization',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ── Progress Header ──
          _buildProgressHeader(context, provider, primary),
          const SizedBox(height: 16),

          // ── Verse Display ──
          Expanded(
            child: _buildVerseArea(context, provider, isDark, primary),
          ),

          // ── Bottom Controls ──
          _buildBottomControls(context, provider, isDark, primary),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    MemorizeProvider provider,
    Color primary,
  ) {
    final total = provider.versesSelected;
    final current = provider.currentAyahIndex + 1;
    final progress = current / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verse $current of $total',
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Ayah ${provider.currentAyahNumber}',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseArea(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.warning),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.currentVerse == null) {
      return Center(
        child: Text(
          'No verse loaded',
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    final gradientDark = Color.lerp(primary, Colors.black, 0.20)!;
    final gradientLight = Color.lerp(primary, Colors.white, 0.15)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Surah + Ayah label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.selectedSurah.name} : Ayah ${provider.currentAyahNumber}',
              style: TextStyle(
                color: primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Arabic verse card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientDark, primary, gradientLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AnimatedCrossFade(
              firstChild: Text(
                provider.currentVerse!['text'] ?? '',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(
                  color: Colors.white,
                  fontSize: 28,
                  height: 2.2,
                ),
              ),
              secondChild: SizedBox(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_off,
                        color: Colors.white.withOpacity(0.4),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to reveal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: provider.isVerseHidden
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: 16),

          // Translation (only when visible)
          if (!provider.isVerseHidden &&
              provider.currentVerse!['translation_en'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                provider.currentVerse!['translation_en'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action buttons row
          Row(
            children: [
              // Hide/Reveal button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.toggleHideReveal,
                  icon: Icon(
                    provider.isVerseHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                  ),
                  label: Text(
                    provider.isVerseHidden ? 'Reveal' : 'Hide',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.cardDark : AppColors.cardLight,
                    foregroundColor: isDark ? Colors.white : AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Memorized button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.markAsMemorized();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Verse marked as memorized! ✅'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      // Auto-advance to next verse
                      if (!provider.isLastVerse) {
                        await provider.nextVerse();
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    'Memorized',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: provider.isFirstVerse
                    ? null
                    : () => provider.previousVerse(),
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                ),
              ),
              TextButton.icon(
                onPressed: provider.isLastVerse
                    ? null
                    : () => provider.nextVerse(),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text('Next'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'memorize_provider.dart';

class MemorizeScreen extends StatelessWidget {
  const MemorizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemorizeProvider()..loadVerse(),
      child: const _MemorizeView(),
    );
  }
}

class _MemorizeView extends StatelessWidget {
  const _MemorizeView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemorizeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Surah Selector ──
          Text(
            'Select Surah',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: provider.selectedSurah,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                items: List.generate(114, (i) {
                  return DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                      '${i + 1}. ${MemorizeProvider.surahNames[i]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) provider.selectSurah(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Ayah Selector ──
          Text(
            'Select Ayah',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: provider.selectedAyah,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                items: List.generate(provider.totalAyahs, (i) {
                  return DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                      'Ayah ${i + 1}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) provider.selectAyah(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Verse Display ──
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
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
          else if (provider.currentVerse != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.memorizeGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Surah name badge
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
                      '${MemorizeProvider.surahNames[provider.selectedSurah - 1]} : ${provider.selectedAyah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Arabic text
                  AnimatedCrossFade(
                    firstChild: Text(
                      provider.currentVerse!['text'] ?? '',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 2.0,
                      ),
                    ),
                    secondChild: Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.visibility_off,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 40,
                      ),
                    ),
                    crossFadeState: provider.isVerseHidden
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 16),

                  // Translation
                  if (!provider.isVerseHidden &&
                      provider.currentVerse!['translation_en'] != null)
                    Text(
                      provider.currentVerse!['translation_en'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ── Action Buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.toggleHideReveal,
                  icon: Icon(
                    provider.isVerseHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  label: Text(
                    provider.isVerseHidden ? 'Reveal' : 'Hide',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                    foregroundColor: isDark ? Colors.white : AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.markAsMemorized();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verse marked as memorized! ✅'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Memorized'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
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
          const SizedBox(height: 12),

          // Navigation arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: provider.selectedAyah > 1
                    ? () => provider.selectAyah(provider.selectedAyah - 1)
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Previous'),
              ),
              TextButton.icon(
                onPressed: provider.selectedAyah < provider.totalAyahs
                    ? () => provider.selectAyah(provider.selectedAyah + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'recite_provider.dart';

class SurahDetailScreen extends StatelessWidget {
  final SurahInfo surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReciteProvider()..loadSurahVerses(surah.number),
      child: _SurahDetailView(surah: surah),
    );
  }
}

class _SurahDetailView extends StatelessWidget {
  final SurahInfo surah;

  const _SurahDetailView({required this.surah});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciteProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.primaryGreen, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          surah.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primaryGreen, size: 20),
              onPressed: () => provider.loadSurahVerses(surah.number),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          _buildHeaderCard(context, isDark),
          const SizedBox(height: 12),

          // Translation toggle
          _buildTranslationToggle(context, provider, isDark),
          const SizedBox(height: 8),

          // Verse list
          Expanded(
            child: _buildVerseList(context, provider, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3BAF8A), Color(0xFF2D9E7D), Color(0xFF1A7A5E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                'Reading',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            surah.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            surah.englishMeaning,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${surah.type} · ${surah.verseCount} Verses',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationToggle(
      BuildContext context, ReciteProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            label: 'English',
            isSelected: provider.translationLang == 'en',
            onTap: () => provider.setTranslationLang('en'),
          ),
          _buildToggleButton(
            label: 'Urdu',
            isSelected: provider.translationLang == 'ur',
            onTap: () => provider.setTranslationLang('ur'),
          ),
          _buildToggleButton(
            label: 'None',
            isSelected: provider.translationLang == 'none',
            onTap: () => provider.setTranslationLang('none'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseList(
      BuildContext context, ReciteProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.warning),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadSurahVerses(surah.number),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // Filter out Bismillah verse (ayah 1 starting with بسم) for all surahs except At-Tawbah
    bool bismillahSkipped = false;
    final filteredVerses = provider.verses.where((verse) {
      final ayah = verse['ayah'] ?? 0;
      final text = (verse['text'] ?? '').toString().trim();
      if (ayah == 1 && surah.number != 9) {
        if (text.startsWith('بِسۡمِ') || text.startsWith('بِسْمِ') || text.startsWith('بسم')) {
          bismillahSkipped = true;
          return false; // Skip Bismillah verse
        }
      }
      return true;
    }).toList();

    // Add Bismillah banner + verses
    final hasBismillah = surah.number != 9;
    final totalItems = hasBismillah ? filteredVerses.length + 1 : filteredVerses.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Show Bismillah banner as first item
        if (hasBismillah && index == 0) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF5EFE0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E7D32).withOpacity(0.3)
                    : const Color(0xFFD4C5A0),
                width: 1.5,
              ),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiriQuran(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : const Color(0xFF333333),
                height: 1.8,
              ),
            ),
          );
        }

        final verseIndex = hasBismillah ? index - 1 : index;
        final verse = filteredVerses[verseIndex];
        int ayahNumber = verse['ayah'] ?? (verseIndex + 1);
        // If Bismillah was skipped (e.g. Al-Fatihah), renumber: ayah 2→1, 3→2, etc.
        if (bismillahSkipped) ayahNumber = ayahNumber - 1;

        return _VerseCard(
          ayahNumber: ayahNumber,
          arabicText: verse['text'] ?? '',
          translationEn: verse['translation_en'],
          translationUr: verse['translation_ur'],
          translationLang: provider.translationLang,
          isDark: isDark,
          surahNumber: surah.number,
          surahName: surah.name,
        );
      },
    );
  }
}

class _VerseCard extends StatelessWidget {
  final int ayahNumber;
  final String arabicText;
  final String? translationEn;
  final String? translationUr;
  final String translationLang;
  final bool isDark;
  final int surahNumber;
  final String surahName;

  const _VerseCard({
    required this.ayahNumber,
    required this.arabicText,
    this.translationEn,
    this.translationUr,
    required this.translationLang,
    required this.isDark,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                // Verse number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$ayahNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Share
                _ActionIcon(
                  icon: Icons.share_outlined,
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                // Play
                _ActionIcon(
                  icon: Icons.play_arrow_rounded,
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                // Bookmark
                _ActionIcon(
                  icon: Icons.bookmark_border,
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Arabic text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiriQuran(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 2.2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Translation
          if (translationLang != 'none') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                _getTranslation(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTranslation() {
    if (translationLang == 'en') {
      return translationEn ?? 'Translation not available';
    } else if (translationLang == 'ur') {
      return translationUr ?? 'Translation not available';
    }
    return '';
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

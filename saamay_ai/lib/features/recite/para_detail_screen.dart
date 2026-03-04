import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'recite_provider.dart';

class ParaDetailScreen extends StatelessWidget {
  final ParaInfo para;

  const ParaDetailScreen({super.key, required this.para});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReciteProvider()..loadJuzVerses(para.number),
      child: _ParaDetailView(para: para),
    );
  }
}

class _ParaDetailView extends StatelessWidget {
  final ParaInfo para;

  const _ParaDetailView({required this.para});

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
          para.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Juz ${para.number}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context, provider, isDark),
    );
  }

  Widget _buildBody(BuildContext context, ReciteProvider provider, bool isDark) {
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
                onPressed: () => provider.loadJuzVerses(para.number),
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

    // Group verses by surah
    final groupedVerses = <int, List<Map<String, dynamic>>>{};
    for (final verse in provider.verses) {
      final surahNum = verse['surah'] as int? ?? 0;
      groupedVerses.putIfAbsent(surahNum, () => []);
      groupedVerses[surahNum]!.add(verse);
    }

    final surahNumbers = groupedVerses.keys.toList()..sort();

    return Container(
      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFF8F0),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: surahNumbers.length,
        itemBuilder: (context, index) {
          final surahNum = surahNumbers[index];
          final verses = groupedVerses[surahNum]!;

          // Find surah info
          String surahName = '';
          String surahArabicName = '';
          for (final s in ReciteProvider.surahs) {
            if (s.number == surahNum) {
              surahName = s.name;
              surahArabicName = s.arabicName;
              break;
            }
          }

          // Check if this is the first ayah of the surah (show header + bismillah)
          final isStartOfSurah = verses.first['ayah'] == 1;

          return Column(
            children: [
              // Surah header banner
              if (isStartOfSurah) ...[
                const SizedBox(height: 12),
                _SurahBanner(
                  surahName: surahName,
                  surahArabicName: surahArabicName,
                  surahNumber: surahNum,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                // Bismillah (except for Surah At-Tawbah = 9)
                if (surahNum != 9)
                  _BismillahBanner(isDark: isDark),
                if (surahNum != 9)
                  const SizedBox(height: 12),
              ],

              // Flowing Arabic text for this surah's verses in this Juz
              _QuranTextBlock(
                verses: verses,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

/// Decorative surah name banner
class _SurahBanner extends StatelessWidget {
  final String surahName;
  final String surahArabicName;
  final int surahNumber;
  final bool isDark;

  const _SurahBanner({
    required this.surahName,
    required this.surahArabicName,
    required this.surahNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
              : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Surah number
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$surahNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // English name
          Expanded(
            child: Text(
              surahName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Arabic name with decorative styling
          Text(
            'سورة $surahArabicName',
            style: GoogleFonts.amiriQuran(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

/// Decorative Bismillah banner
class _BismillahBanner extends StatelessWidget {
  final bool isDark;

  const _BismillahBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
}

/// Flowing Quran text block — all verses from one surah in a single block
class _QuranTextBlock extends StatelessWidget {
  final List<Map<String, dynamic>> verses;
  final bool isDark;

  const _QuranTextBlock({
    required this.verses,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Build flowing text with verse number markers
    final List<InlineSpan> spans = [];
    final Set<int> _bismillahSkippedSurahs = {};

    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      String text = verse['text'] ?? '';
      int ayahNum = verse['ayah'] ?? (i + 1);
      final surahNum = verse['surah'] ?? 0;

      // Skip Bismillah from first ayah (it's already shown as a banner)
      if (ayahNum == 1 && surahNum != 9) {
        // Check if the verse text starts with بسم (any Bismillah variant)
        final trimmed = text.trim();
        if (trimmed.startsWith('بِسۡمِ') || trimmed.startsWith('بِسْمِ') || trimmed.startsWith('بسم')) {
          // Mark this surah as having Bismillah skipped
          _bismillahSkippedSurahs.add(surahNum);
          continue;
        }
      }

      // If this surah had Bismillah skipped, renumber: ayah 2→1, 3→2, etc.
      if (_bismillahSkippedSurahs.contains(surahNum)) {
        ayahNum = ayahNum - 1;
      }

      // Arabic verse text
      spans.add(TextSpan(
        text: text,
        style: GoogleFonts.amiriQuran(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : const Color(0xFF333333),
          height: 2.4,
        ),
      ));

      // Verse number marker (like ﴿١﴾)
      spans.add(TextSpan(
        text: ' \u06DD${_toArabicNumeral(ayahNum)} ',
        style: GoogleFonts.amiriQuran(
          fontSize: 22,
          color: AppColors.primaryGreen,
          height: 2.4,
        ),
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFE0D8C8),
        ),
      ),
      child: RichText(
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        text: TextSpan(children: spans),
      ),
    );
  }

  /// Remove Bismillah text from the beginning of a verse
  String _removeBismillah(String text) {
    // Exact Bismillah text from the database (with special Unicode chars)
    const bismillahVariants = [
      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',  // Exact DB text
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'بسم الله الرحمن الرحيم',
      'بِسمِ اللَّهِ الرَّحمٰنِ الرَّحيمِ',
    ];
    
    String result = text.trim();
    for (final bismillah in bismillahVariants) {
      if (result.contains(bismillah)) {
        result = result.replaceFirst(bismillah, '').trim();
        return result;
      }
    }
    
    // Fallback: regex-based removal for any Bismillah variant
    // Match any text starting with بسم and ending near الرحيم
    final regex = RegExp(r'بِ?سۡ?مِ?\s+[ٱا]للَّهِ\s+[ٱا]لرَّحۡ?مَٰ?نِ\s+[ٱا]لرَّحِيمِ');
    if (regex.hasMatch(result)) {
      result = result.replaceFirst(regex, '').trim();
    }
    
    return result;
  }

  /// Convert number to Arabic-Indic numerals
  String _toArabicNumeral(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicNumerals[int.parse(d)]).join();
  }
}

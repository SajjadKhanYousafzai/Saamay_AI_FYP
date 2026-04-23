import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../recite/recite_provider.dart';
import 'memorize_provider.dart';
import 'memorize_session_screen.dart';

class MemorizeScreen extends StatelessWidget {
  const MemorizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemorizeProvider(),
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
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Memorization Mode Banner ──
          _buildBanner(context, primary),
          const SizedBox(height: 28),

          // ── Select Surah ──
          Text(
            'Select Surah',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 10),
          _buildSurahSelector(context, provider, isDark, primary),
          const SizedBox(height: 28),

          // ── Select Ayah Range ──
          Text(
            'Select Ayah Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 10),
          _buildAyahRange(context, provider, isDark, primary),
          const SizedBox(height: 20),

          // ── Verses Selected Indicator ──
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.versesSelected} verses selected',
                    style: TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Start Memorizing Button ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                await provider.startSession();
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: const MemorizeSessionScreen(),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primary.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Start Memorizing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, Color primary) {
    final gradientDark = Color.lerp(primary, Colors.black, 0.15)!;
    final gradientLight = Color.lerp(primary, Colors.white, 0.20)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientDark, primary, gradientLight],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Transparent book image overlay
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/book.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Memorization Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Surah and verses. Recite to reveal text.\nGreen = correct, Red = mistakes.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.5,
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

  Widget _buildSurahSelector(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    final surah = provider.selectedSurah;

    return GestureDetector(
      onTap: () => _showSurahPicker(context, provider, isDark, primary),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.number}',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Surah name
            Expanded(
              child: Text(
                surah.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            // Arabic name
            Text(
              surah.arabicName,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiriQuran(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahPicker(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Surah',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: ReciteProvider.surahs.length,
                    itemBuilder: (_, i) {
                      final s = ReciteProvider.surahs[i];
                      final isSelected = i == provider.selectedSurahIndex;
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.2)
                                : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${s.number}',
                            style: TextStyle(
                              color: isSelected ? primary : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primary : null,
                          ),
                        ),
                        subtitle: Text(
                          '${s.type} • ${s.verseCount} verses',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                        trailing: Text(
                          s.arabicName,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiriQuran(
                            fontSize: 16,
                            color: isSelected ? primary : null,
                          ),
                        ),
                        onTap: () {
                          provider.selectSurah(i);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAyahRange(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    return Row(
      children: [
        // Start counter
        Expanded(
          child: _buildCounter(
            context: context,
            label: 'Start',
            value: provider.startAyah,
            maxValue: provider.totalAyahs,
            onIncrement: provider.incrementStart,
            onDecrement: provider.decrementStart,
            isDark: isDark,
            primary: primary,
          ),
        ),
        // Arrow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 22,
          ),
        ),
        // End counter
        Expanded(
          child: _buildCounter(
            context: context,
            label: 'End',
            value: provider.endAyah,
            maxValue: provider.totalAyahs,
            onIncrement: provider.incrementEnd,
            onDecrement: provider.decrementEnd,
            isDark: isDark,
            primary: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required BuildContext context,
    required String label,
    required int value,
    required int maxValue,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool isDark,
    required Color primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // −  value  +
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Value — use FittedBox for large numbers
              SizedBox(
                width: 50,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Plus button
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add,
                    color: primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Max indicator
          Text(
            'Max: $maxValue',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

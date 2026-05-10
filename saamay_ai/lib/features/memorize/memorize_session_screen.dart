import 'dart:math';
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
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ??
        (isDark ? AppColors.cardDark : AppColors.cardLight);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                Color.lerp(primary, Colors.black, 0.25)!,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () async {
            if (provider.isListening) await provider.stopListening();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              surah.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Verse ${provider.startAyah} – ${provider.endAyah}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          // Progress indicator in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  '${provider.completedVerses}/${provider.verseStates.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable verse area ──
          Expanded(
            child: _buildBody(context, provider, isDark, primary, cardColor),
          ),
          // ── Bottom section: Legend + Mic ──
          _buildBottomSection(context, provider, isDark, primary, cardColor),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
    Color cardColor,
  ) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning.withOpacity(0.1),
                ),
                child: const Icon(Icons.error_outline, size: 32, color: AppColors.warning),
              ),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.verseStates.isEmpty) {
      return Center(
        child: Text('No verses loaded', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    // Session complete
    if (provider.isSessionComplete) {
      return _buildCompletionScreen(context, provider, isDark, primary, cardColor);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // ── Surah Header (ornate style) ──
          _buildSurahHeader(context, provider, isDark, primary),
          const SizedBox(height: 14),

          // ── Bismillah ──
          if (provider.selectedSurah.number != 9)
            _buildBismillah(context, isDark, primary, cardColor),
          const SizedBox(height: 20),

          // ── Verse word blocks ──
          ...provider.verseStates.asMap().entries.map((entry) {
            final verseIndex = entry.key;
            final verse = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildVerseRow(context, verse, verseIndex, provider, isDark, primary, cardColor),
            );
          }),

          const SizedBox(height: 16),

          // ── Finish Session Button (shown when all verses are done) ──
          if (provider.allVersesCompleted) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.finishSession(),
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: const Text('Finish Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ── SURAH HEADER ──
  // ═══════════════════════════════════════════════════
  Widget _buildSurahHeader(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    final outerFrame = isDark
        ? Color.lerp(primary, Colors.black, 0.65)!
        : Color.lerp(primary, const Color(0xFFF5EFE0), 0.5)!;
    final panelBg = isDark
        ? Color.lerp(primary, Colors.black, 0.82)!
        : Color.lerp(primary, Colors.white, 0.88)!;
    final ornamentColor = isDark
        ? Color.lerp(primary, Colors.white, 0.35)!
        : Color.lerp(primary, const Color(0xFF8B7355), 0.4)!;
    final borderColor = isDark
        ? primary.withOpacity(0.35)
        : Color.lerp(primary, const Color(0xFF8B7355), 0.3)!;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1810);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: outerFrame,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: CustomPaint(
          painter: _OrnateHeaderPainter(
            ornamentColor: ornamentColor,
            innerFrame: outerFrame,
            isDark: isDark,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Row(
              children: [
                // Left ornament panel
                _buildOrnamentPanel(ornamentColor, outerFrame, isDark),
                // Center: Surah name
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ornamentColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDecorativeDivider(ornamentColor),
                        const SizedBox(height: 8),
                        Text(
                          'سورة ${provider.selectedSurah.arabicName}',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiriQuran(
                            fontSize: 24,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDecorativeDivider(ornamentColor),
                      ],
                    ),
                  ),
                ),
                // Right ornament panel
                _buildOrnamentPanel(ornamentColor, outerFrame, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrnamentPanel(Color ornamentColor, Color innerFrame, bool isDark) {
    return Container(
      width: 42,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: innerFrame,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ornamentColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMotif('❋', ornamentColor, 14),
          const SizedBox(height: 3),
          _buildMotif('✦', ornamentColor, 8),
          const SizedBox(height: 2),
          Container(width: 20, height: 1, color: ornamentColor.withOpacity(0.3)),
          const SizedBox(height: 2),
          _buildMotif('❀', ornamentColor, 12),
          const SizedBox(height: 2),
          Container(width: 20, height: 1, color: ornamentColor.withOpacity(0.3)),
          const SizedBox(height: 2),
          _buildMotif('✦', ornamentColor, 8),
          const SizedBox(height: 3),
          _buildMotif('❋', ornamentColor, 14),
        ],
      ),
    );
  }

  Widget _buildMotif(String char, Color color, double size) {
    return Text(char, style: TextStyle(color: color, fontSize: size, height: 1));
  }

  Widget _buildDecorativeDivider(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 24, height: 0.8, color: color.withOpacity(0.3)),
        const SizedBox(width: 4),
        Text('✧', style: TextStyle(color: color, fontSize: 8)),
        const SizedBox(width: 6),
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 0.8),
          ),
          child: Center(
            child: Container(
              width: 2, height: 2,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.6)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('✧', style: TextStyle(color: color, fontSize: 8)),
        const SizedBox(width: 4),
        Container(width: 24, height: 0.8, color: color.withOpacity(0.3)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // ── BISMILLAH ──
  // ═══════════════════════════════════════════════════
  Widget _buildBismillah(BuildContext context, bool isDark, Color primary, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [cardBg, Color.lerp(cardBg, primary, 0.05)!]
              : [Color.lerp(primary, Colors.white, 0.92)!, Color.lerp(primary, Colors.white, 0.96)!],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(isDark ? 0.15 : 0.2)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiriQuran(
          fontSize: 22,
          color: isDark ? Colors.white : const Color(0xFF333333),
          height: 1.6,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ── VERSE ROW ──
  // ═══════════════════════════════════════════════════
  Widget _buildVerseRow(
    BuildContext context,
    VerseState verse,
    int verseIndex,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
    Color cardColor,
  ) {
    final isCurrent = verseIndex == provider.currentVerseIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? primary.withOpacity(0.06) : primary.withOpacity(0.04))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: primary.withOpacity(0.25), width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Ayah label badge (only for current verse)
          if (isCurrent && !verse.isCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none, color: primary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Ayah ${verse.ayahNumber}',
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (verse.lastAccuracy != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: verse.lastAccuracy! >= 80 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: verse.lastAccuracy! >= 80 ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        '${verse.lastAccuracy!.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: verse.lastAccuracy! >= 80 ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Word blocks
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              spacing: 7,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                // Ayah number marker
                _buildAyahCircle(verse.ayahNumber, isDark, primary),
                // Words
                ...verse.words.asMap().entries.map((wordEntry) {
                  final wordIndex = wordEntry.key;
                  final word = wordEntry.value;
                  final state = verse.wordStates[wordIndex];
                  return _buildWordBlock(word, state, isDark, primary);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCircle(int number, bool isDark, Color primary) {
    final circleColor = isDark
        ? Color.lerp(primary, Colors.white, 0.3)!
        : Color.lerp(primary, Colors.brown, 0.3)!;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            circleColor.withOpacity(0.2),
            circleColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: circleColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: circleColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWordBlock(String word, WordState state, bool isDark, Color primary) {
    Color bgColor;
    Color textColor;
    String displayText;
    final accentHighlight = Color.lerp(primary, Colors.amber, 0.5)!;
    Color? borderCol;

    switch (state) {
      case WordState.hidden:
      case WordState.pending:
        bgColor = isDark
            ? primary.withOpacity(0.07)
            : Colors.grey.shade200;
        textColor = Colors.transparent;
        displayText = '•' * (word.length > 4 ? 4 : word.length).clamp(2, 5);
        break;
      case WordState.current:
        bgColor = isDark
            ? accentHighlight.withOpacity(0.15)
            : accentHighlight.withOpacity(0.12);
        textColor = Colors.transparent;
        displayText = '•' * (word.length > 4 ? 4 : word.length).clamp(2, 5);
        borderCol = accentHighlight.withOpacity(0.5);
        break;
      case WordState.correct:
        bgColor = AppColors.success.withOpacity(isDark ? 0.18 : 0.12);
        textColor = isDark ? Colors.white : const Color(0xFF333333);
        displayText = word;
        borderCol = AppColors.success.withOpacity(0.3);
        break;
      case WordState.mistake:
        bgColor = AppColors.error.withOpacity(isDark ? 0.18 : 0.12);
        textColor = isDark ? Colors.white : const Color(0xFF333333);
        displayText = word;
        borderCol = AppColors.error.withOpacity(0.3);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: borderCol != null ? Border.all(color: borderCol, width: 1.5) : null,
      ),
      child: state == WordState.hidden || state == WordState.current
          ? Text(
              displayText,
              style: TextStyle(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            )
          : Text(
              displayText,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiriQuran(
                color: textColor,
                fontSize: 18,
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ── BOTTOM SECTION ──
  // ═══════════════════════════════════════════════════
  Widget _buildBottomSection(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Legend row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildLegendItem('Correct', AppColors.success, isDark),
              _buildLegendItem('Mistake', AppColors.error, isDark),
              _buildLegendItem(
                'Hidden',
                isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade400,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              provider.isPlayingCorrection
                  ? '🔊 Listening to original recitation...'
                  : provider.isListening
                      ? 'Listening... recite the verse'
                      : (provider.isSessionComplete
                          ? 'Session complete! 🎉'
                          : 'Tap to start reciting'),
              key: ValueKey(provider.isListening.toString() + provider.isSessionComplete.toString() + provider.isPlayingCorrection.toString()),
              style: TextStyle(
                color: provider.isPlayingCorrection || provider.isListening ? primary : (isDark ? Colors.white60 : Colors.black45),
                fontSize: 14,
                fontWeight: provider.isPlayingCorrection || provider.isListening ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          if (provider.lastRecognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                provider.lastRecognizedText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),

          // Action row: Skip + Mic + Reveal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip word button
              if (!provider.isSessionComplete)
                _buildActionButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Skip',
                  onTap: provider.skipVerse,
                  isDark: isDark,
                  primary: primary,
                ),

              const SizedBox(width: 20),

              // Microphone button (animated)
              _AnimatedMicButton(
                isListening: provider.isListening,
                isDisabled: provider.isSessionComplete || provider.isPlayingCorrection,
                primary: primary,
                onTap: provider.toggleListening,
              ),

              const SizedBox(width: 20),

              // Reveal word button
              if (!provider.isSessionComplete)
                _buildActionButton(
                  icon: Icons.visibility_rounded,
                  label: 'Reveal',
                  onTap: provider.revealCurrentVerse,
                  isDark: isDark,
                  primary: primary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
            ),
            child: Icon(icon, color: isDark ? Colors.white60 : Colors.black45, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ── COMPLETION SCREEN ──
  // ═══════════════════════════════════════════════════
  Widget _buildCompletionScreen(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
    Color cardColor,
  ) {
    int totalCorrect = 0;
    int totalMistakes = 0;
    for (final verse in provider.verseStates) {
      for (final state in verse.wordStates) {
        if (state == WordState.correct) totalCorrect++;
        if (state == WordState.mistake) totalMistakes++;
      }
    }
    final totalWords = totalCorrect + totalMistakes;
    final accuracy = totalWords > 0 ? (totalCorrect / totalWords * 100) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Trophy icon with glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, Color.lerp(primary, Colors.amber, 0.3)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),

          Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.selectedSurah.name} — Ayah ${provider.startAyah}–${provider.endAyah}',
            style: TextStyle(color: AppColors.textGrey, fontSize: 15),
          ),
          const SizedBox(height: 32),

          // Stats cards
          Row(
            children: [
              _statCard('Accuracy', '${accuracy.toStringAsFixed(0)}%', primary, isDark),
              const SizedBox(width: 12),
              _statCard('Correct', '$totalCorrect', AppColors.success, isDark),
              const SizedBox(width: 12),
              _statCard('Mistakes', '$totalMistakes', AppColors.error, isDark),
            ],
          ),
          const SizedBox(height: 36),

          // Save & Exit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.saveProgress();
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Save & Exit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primary.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
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

// ═══════════════════════════════════════════════════
// ── ANIMATED MIC BUTTON ──
// ═══════════════════════════════════════════════════
class _AnimatedMicButton extends StatefulWidget {
  final bool isListening;
  final bool isDisabled;
  final Color primary;
  final VoidCallback onTap;

  const _AnimatedMicButton({
    required this.isListening,
    required this.isDisabled,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<_AnimatedMicButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat();
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isListening ? AppColors.error : widget.primary;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        if (!widget.isDisabled) widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnim, _scaleAnim]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse rings
                  if (widget.isListening) ...[
                    _buildPulseRing(84, activeColor, _pulseAnim.value, 0.0),
                    _buildPulseRing(76, activeColor, _pulseAnim.value, 0.15),
                    _buildPulseRing(70, activeColor, _pulseAnim.value, 0.3),
                  ],

                  // Glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(widget.isListening ? 0.5 : 0.2),
                          blurRadius: widget.isListening ? 26 : 12,
                          spreadRadius: widget.isListening ? 4 : 0,
                        ),
                      ],
                    ),
                  ),

                  // Main button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isListening
                            ? [AppColors.error, Color.lerp(AppColors.error, Colors.red.shade900, 0.3)!]
                            : [
                                Color.lerp(widget.primary, Colors.white, 0.15)!,
                                widget.primary,
                                Color.lerp(widget.primary, Colors.black, 0.15)!,
                              ],
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        widget.isListening ? Icons.stop_rounded : Icons.mic,
                        key: ValueKey(widget.isListening),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(double maxSize, Color color, double progress, double delay) {
    final adjustedProgress = ((progress + delay) % 1.0);
    final size = 54 + (maxSize - 54) * adjustedProgress;
    final opacity = (1.0 - adjustedProgress) * 0.4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity.clamp(0.0, 1.0)),
          width: 2.5 * (1.0 - adjustedProgress * 0.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// ── ORNATE HEADER PAINTER ──
// ═══════════════════════════════════════════════════
class _OrnateHeaderPainter extends CustomPainter {
  final Color ornamentColor;
  final Color innerFrame;
  final bool isDark;

  _OrnateHeaderPainter({
    required this.ornamentColor,
    required this.innerFrame,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ornamentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(5),
    );
    canvas.drawRRect(frameRect, paint);

    _drawCornerDecor(canvas, paint, 0, 0, 1, 1);
    _drawCornerDecor(canvas, paint, size.width, 0, -1, 1);
    _drawCornerDecor(canvas, paint, 0, size.height, 1, -1);
    _drawCornerDecor(canvas, paint, size.width, size.height, -1, -1);
  }

  void _drawCornerDecor(Canvas canvas, Paint paint, double x, double y, double dx, double dy) {
    final p = Paint()
      ..color = ornamentColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(x + dx * 8, y + dy * 2)
      ..quadraticBezierTo(x + dx * 2, y + dy * 2, x + dx * 2, y + dy * 8);
    canvas.drawPath(path, p);

    final path2 = Path()
      ..moveTo(x + dx * 14, y + dy * 2)
      ..quadraticBezierTo(x + dx * 2, y + dy * 2, x + dx * 2, y + dy * 14);
    canvas.drawPath(path2, p..color = ornamentColor.withOpacity(0.1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

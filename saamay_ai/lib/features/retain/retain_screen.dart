import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../recite/recite_provider.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    // If custom selection mode
    if (provider.isCustomMode) {
      return _buildSurahSelector(context, provider, isDark, primary);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ──
          Row(
            children: [
              _statCard(context, label: 'Correct', value: '${provider.correctCount}', color: AppColors.success, isDark: isDark),
              const SizedBox(width: 10),
              _statCard(context, label: 'Incorrect', value: '${provider.incorrectCount}', color: AppColors.error, isDark: isDark),
              const SizedBox(width: 10),
              _statCard(context, label: 'Rate', value: '${provider.successRate.toStringAsFixed(0)}%', color: primary, isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),

          // ── Mode Toggle ──
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {}, // Already in random mode
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🎲 Random', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setCustomMode(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text('📖 Select Ayah', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quiz Area ──
          if (provider.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: CircularProgressIndicator(color: primary),
              ),
            )
          else if (provider.error != null)
            _buildErrorCard(provider.error!)
          else if (provider.currentQuizVerse != null) ...[
            _buildQuizCard(context, provider, isDark, primary),
            const SizedBox(height: 20),
            _buildActionButtons(context, provider, isDark, primary),
          ],
        ],
      ),
    );
  }

  // ── Quiz Card ──
  Widget _buildQuizCard(BuildContext context, RetainProvider provider, bool isDark, Color primary) {
    final verse = provider.currentQuizVerse!;
    final surahNum = verse['surah'] as int? ?? 1;
    final ayahNum = verse['ayah'] as int? ?? 1;
    final surahInfo = ReciteProvider.surahs.firstWhere(
      (s) => s.number == surahNum,
      orElse: () => ReciteProvider.surahs[0],
    );

    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${surahInfo.name}  •  Ayah $ayahNum',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // Status text
          if (provider.statusText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: provider.lastAccuracy != null && provider.lastAccuracy! >= 80
                    ? Colors.green.withOpacity(0.2)
                    : provider.lastAccuracy != null
                        ? Colors.red.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                provider.statusText,
                style: TextStyle(
                  color: provider.lastAccuracy != null && provider.lastAccuracy! >= 80
                      ? Colors.greenAccent
                      : provider.lastAccuracy != null
                          ? Colors.redAccent
                          : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Prompt
          if (!provider.isVerseRevealed && !provider.isListening && !provider.isProcessing)
            Text(
              'Can you recall this verse?',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),

          const SizedBox(height: 16),

          // Verse Area
          AnimatedCrossFade(
            firstChild: Container(
              width: double.infinity,
              height: 100,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, color: Colors.white.withOpacity(0.4), size: 40),
                  const SizedBox(height: 8),
                  Text(
                    provider.isListening ? '🎙️ Recording...' :
                    provider.isProcessing ? '⏳ Processing...' :
                    'Tap mic to recite or "Reveal" to see',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            secondChild: _buildRevealedVerse(provider, isDark),
            crossFadeState: provider.isVerseRevealed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // Accuracy badge
          if (provider.lastAccuracy != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: provider.lastAccuracy! >= 80 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: provider.lastAccuracy! >= 80 ? Colors.green : Colors.red),
              ),
              child: Text(
                '${provider.lastAccuracy!.toStringAsFixed(0)}% Accuracy',
                style: TextStyle(
                  color: provider.lastAccuracy! >= 80 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRevealedVerse(RetainProvider provider, bool isDark) {
    // If we have word-level feedback, show colored words
    if (provider.currentWords.isNotEmpty && provider.wordStates.isNotEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          spacing: 6,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(provider.currentWords.length, (i) {
            final word = provider.currentWords[i];
            final state = provider.wordStates[i];
            Color bgColor;
            if (state == RetainWordState.correct) {
              bgColor = Colors.green.withOpacity(0.3);
            } else if (state == RetainWordState.mistake) {
              bgColor = Colors.red.withOpacity(0.3);
            } else {
              bgColor = Colors.transparent;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(color: Colors.white, fontSize: 22, height: 1.8),
              ),
            );
          }),
        ),
      );
    }

    // Plain reveal (no recording attempt)
    return Column(
      children: [
        Text(
          provider.currentQuizVerse!['text'] ?? '',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiriQuran(color: Colors.white, fontSize: 24, height: 2.0),
        ),
        if (provider.currentQuizVerse!['translation_en'] != null) ...[
          const SizedBox(height: 12),
          Text(
            provider.currentQuizVerse!['translation_en'],
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ],
    );
  }

  // ── Action Buttons ──
  Widget _buildActionButtons(BuildContext context, RetainProvider provider, bool isDark, Color primary) {
    return Column(
      children: [
        // Record / Stop Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip
            GestureDetector(
              onTap: provider.nextVerse,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.skip_next, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(width: 20),

            // Mic Button
            GestureDetector(
              onTap: provider.isProcessing ? null : provider.toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: provider.isListening ? AppColors.error : primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (provider.isListening ? AppColors.error : primary).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  provider.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Reveal
            GestureDetector(
              onTap: provider.revealVerse,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility, color: AppColors.textGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 50, child: Text('Skip', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey, fontSize: 11))),
            const SizedBox(width: 20),
            SizedBox(
              width: 72,
              child: Text(
                provider.isListening ? 'Stop' : 'Recite',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 20),
            const SizedBox(width: 50, child: Text('Reveal', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey, fontSize: 11))),
          ],
        ),

        // Correction audio indicator
        if (provider.isPlayingCorrection) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up, color: AppColors.warning, size: 18),
                SizedBox(width: 8),
                Text('Listening to correct recitation...', style: TextStyle(color: AppColors.warning, fontSize: 13)),
              ],
            ),
          ),
        ],

        // After reveal: manual correct/incorrect
        if (provider.isVerseRevealed && provider.lastAccuracy == null) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.markIncorrect,
                  icon: const Icon(Icons.close),
                  label: const Text('Incorrect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.2),
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],

        // After recording: Next button
        if (provider.lastAccuracy != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.nextVerse,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Verse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Surah/Ayah Selector ──
  Widget _buildSurahSelector(BuildContext context, RetainProvider provider, bool isDark, Color primary) {
    final surah = provider.selectedSurah;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back to random
          GestureDetector(
            onTap: () => provider.setCustomMode(false),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: primary, size: 16),
                const SizedBox(width: 4),
                Text('Back to Quiz', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Select Surah', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Surah Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: provider.selectedSurahIndex,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              underline: const SizedBox(),
              style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 15),
              items: List.generate(ReciteProvider.surahs.length, (i) {
                final s = ReciteProvider.surahs[i];
                return DropdownMenuItem(value: i, child: Text('${s.number}. ${s.name}'));
              }),
              onChanged: (v) {
                if (v != null) provider.selectSurah(v);
              },
            ),
          ),
          const SizedBox(height: 20),

          Text('Select Ayah (1 - ${provider.maxAyah})', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Ayah Number Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: primary,
                  onPressed: () {
                    if (provider.selectedAyah > 1) provider.selectAyah(provider.selectedAyah - 1);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${provider.selectedAyah}',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: primary,
                  onPressed: () {
                    if (provider.selectedAyah < provider.maxAyah) provider.selectAyah(provider.selectedAyah + 1);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.loadCustomVerse,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test This Verse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Text(error, style: const TextStyle(color: AppColors.warning), textAlign: TextAlign.center),
    );
  }

  Widget _statCard(BuildContext context, {required String label, required String value, required Color color, required bool isDark}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isDark ? AppColors.textGrey : Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

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

    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = colorScheme.surface;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            if (provider.isListening) await provider.stopListening();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter ${surah.name}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Verse ${provider.startAyah} - ${provider.endAyah}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Settings bottom sheet could go here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable verse area ──
          Expanded(
            child: _buildBody(context, provider, isDark, primary),
          ),

          // ── Bottom section: Legend + Mic ──
          _buildBottomSection(context, provider, isDark, primary),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
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

    if (provider.verseStates.isEmpty) {
      return Center(
        child: Text('No verses loaded', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    // Session complete
    if (provider.isSessionComplete) {
      return _buildCompletionScreen(context, provider, isDark, primary);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // ── Surah Header (ornate style) ──
          _buildSurahHeader(context, provider, isDark, primary),
          const SizedBox(height: 12),

          // ── Bismillah ──
          if (provider.selectedSurah.number != 9)
            _buildBismillah(context, isDark),
          const SizedBox(height: 16),

          // ── Verse word blocks ──
          ...provider.verseStates.asMap().entries.map((entry) {
            final verseIndex = entry.key;
            final verse = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVerseRow(context, verse, verseIndex, provider, isDark, primary),
            );
          }),

          // ── Progress badge ──
          _buildProgressBadge(provider, primary),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    // Derive ornament palette from the current theme primary color
    final outerFrame = isDark
        ? Color.lerp(primary, Colors.black, 0.7)!
        : Color.lerp(primary, const Color(0xFFF5EFE0), 0.5)!;
    final innerFrame = isDark
        ? Color.lerp(primary, Colors.black, 0.6)!
        : Color.lerp(primary, const Color(0xFFF5EFE0), 0.35)!;
    final panelBg = isDark
        ? Color.lerp(primary, Colors.black, 0.85)!
        : Color.lerp(primary, Colors.white, 0.85)!;
    final ornamentColor = isDark
        ? Color.lerp(primary, Colors.white, 0.3)!
        : Color.lerp(primary, const Color(0xFF8B7355), 0.4)!;
    final borderColor = isDark
        ? primary.withOpacity(0.3)
        : Color.lerp(primary, const Color(0xFF8B7355), 0.3)!;
    final textColor = isDark ? Colors.white : const Color(0xFF2C1810);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: outerFrame,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CustomPaint(
          painter: _OrnateHeaderPainter(
            ornamentColor: ornamentColor,
            innerFrame: innerFrame,
            isDark: isDark,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                // Left ornament panel
                _buildOrnamentPanel(ornamentColor, innerFrame, isDark),

                // Center: Surah name in elegant frame
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: ornamentColor.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ornamentColor.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top decorative line
                        _buildDecorativeDivider(ornamentColor),
                        const SizedBox(height: 6),
                        // Arabic surah name
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
                        const SizedBox(height: 6),
                        // Bottom decorative line
                        _buildDecorativeDivider(ornamentColor),
                      ],
                    ),
                  ),
                ),

                // Right ornament panel
                _buildOrnamentPanel(ornamentColor, innerFrame, isDark),
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
        border: Border.all(
          color: ornamentColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ornamental floral motifs (using Unicode symbols)
          _buildMotif('❋', ornamentColor, 14),
          const SizedBox(height: 3),
          _buildMotif('✦', ornamentColor, 8),
          const SizedBox(height: 2),
          Container(
            width: 20,
            height: 1,
            color: ornamentColor.withOpacity(0.3),
          ),
          const SizedBox(height: 2),
          _buildMotif('❀', ornamentColor, 12),
          const SizedBox(height: 2),
          Container(
            width: 20,
            height: 1,
            color: ornamentColor.withOpacity(0.3),
          ),
          const SizedBox(height: 2),
          _buildMotif('✦', ornamentColor, 8),
          const SizedBox(height: 3),
          _buildMotif('❋', ornamentColor, 14),
        ],
      ),
    );
  }

  Widget _buildMotif(String char, Color color, double size) {
    return Text(
      char,
      style: TextStyle(
        color: color,
        fontSize: size,
        height: 1,
      ),
    );
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 0.8),
          ),
          child: Center(
            child: Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.6),
              ),
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

  Widget _buildBismillah(BuildContext context, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? cardBg : Color.lerp(primary, Colors.white, 0.9)!,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withOpacity(isDark ? 0.2 : 0.3),
        ),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiriQuran(
          fontSize: 20,
          color: isDark ? Colors.white : const Color(0xFF333333),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildVerseRow(
    BuildContext context,
    VerseState verse,
    int verseIndex,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    final isCurrent = verseIndex == provider.currentVerseIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? primary.withOpacity(0.05) : primary.withOpacity(0.03))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: primary.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Ayah label (if current verse is being worked on)
          if (isCurrent && !verse.isCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ayah ${verse.ayahNumber}',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Word blocks
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: circleColor,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: circleColor,
          fontSize: 11,
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

    switch (state) {
      case WordState.hidden:
        bgColor = isDark
            ? primary.withOpacity(0.06)
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
        break;
      case WordState.correct:
        bgColor = AppColors.success.withOpacity(isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.white : const Color(0xFF333333);
        displayText = word;
        break;
      case WordState.mistake:
        bgColor = AppColors.error.withOpacity(isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.white : const Color(0xFF333333);
        displayText = word;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: state == WordState.current
            ? Border.all(color: accentHighlight.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: state == WordState.hidden || state == WordState.current
          ? Text(
              displayText,
              style: TextStyle(
                color: isDark ? Colors.white30 : Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
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

  Widget _buildProgressBadge(MemorizeProvider provider, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Text(
        'Progress: ${provider.completedVerses}/${provider.verseStates.length} verses',
        style: TextStyle(
          color: primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 16),

          // Status text
          Text(
            provider.isListening
                ? 'Listening... recite the verse'
                : (provider.isSessionComplete
                    ? 'Session complete! 🎉'
                    : 'Tap to start reciting'),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Action row: Skip + Mic + Reveal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip word button
              if (!provider.isSessionComplete)
                IconButton(
                  onPressed: provider.skipWord,
                  icon: Icon(
                    Icons.skip_next,
                    color: isDark ? Colors.white54 : Colors.black38,
                    size: 28,
                  ),
                  tooltip: 'Skip word',
                ),

              const SizedBox(width: 16),

              // Microphone button (animated)
              _AnimatedMicButton(
                isListening: provider.isListening,
                isDisabled: provider.isSessionComplete,
                primary: primary,
                onTap: provider.toggleListening,
              ),

              const SizedBox(width: 16),

              // Reveal word button
              if (!provider.isSessionComplete)
                IconButton(
                  onPressed: provider.revealCurrentWord,
                  icon: Icon(
                    Icons.visibility,
                    color: isDark ? Colors.white54 : Colors.black38,
                    size: 28,
                  ),
                  tooltip: 'Reveal word',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
        ),
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

  Widget _buildCompletionScreen(
    BuildContext context,
    MemorizeProvider provider,
    bool isDark,
    Color primary,
  ) {
    // Calculate stats
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
          const SizedBox(height: 32),
          Icon(Icons.celebration, size: 64, color: primary),
          const SizedBox(height: 16),
          Text(
            'Session Complete!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.selectedSurah.name} — Ayah ${provider.startAyah}-${provider.endAyah}',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 15,
            ),
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
          const SizedBox(height: 32),

          // Save & Exit button
          SizedBox(
            width: double.infinity,
            height: 52,
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
                  borderRadius: BorderRadius.circular(14),
                ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
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

/// Premium animated microphone button with pulsing rings when listening
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

    // Pulse animation (loops when listening)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Scale animation (bounce on tap)
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
                  // Outer pulse ring 3 (largest)
                  if (widget.isListening)
                    _buildPulseRing(82, activeColor, _pulseAnim.value, 0.0),

                  // Outer pulse ring 2
                  if (widget.isListening)
                    _buildPulseRing(74, activeColor, _pulseAnim.value, 0.15),

                  // Inner pulse ring 1
                  if (widget.isListening)
                    _buildPulseRing(68, activeColor, _pulseAnim.value, 0.3),

                  // Glow background (always visible, stronger when listening)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(
                            widget.isListening ? 0.5 : 0.25,
                          ),
                          blurRadius: widget.isListening ? 24 : 12,
                          spreadRadius: widget.isListening ? 4 : 0,
                        ),
                      ],
                    ),
                  ),

                  // Main button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isListening
                            ? [
                                AppColors.error,
                                Color.lerp(AppColors.error, Colors.red.shade900, 0.3)!,
                              ]
                            : [
                                Color.lerp(widget.primary, Colors.white, 0.15)!,
                                widget.primary,
                                Color.lerp(widget.primary, Colors.black, 0.15)!,
                              ],
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
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

/// CustomPainter for the ornate Mushaf-style header background decorations
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

    // Inner border frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(5),
    );
    canvas.drawRRect(frameRect, paint);

    // Corner decorative curves (top-left)
    _drawCornerDecor(canvas, paint, 0, 0, 1, 1);
    // Top-right
    _drawCornerDecor(canvas, paint, size.width, 0, -1, 1);
    // Bottom-left
    _drawCornerDecor(canvas, paint, 0, size.height, 1, -1);
    // Bottom-right
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

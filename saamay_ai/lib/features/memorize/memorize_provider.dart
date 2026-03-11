import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/database_service.dart';
import '../recite/recite_provider.dart';

/// State for each word in a verse
enum WordState { hidden, current, correct, mistake }

/// Holds the state of a single verse during memorization
class VerseState {
  final int ayahNumber;
  final String fullText;
  final List<String> words;
  final List<WordState> wordStates;
  bool isCompleted;

  VerseState({
    required this.ayahNumber,
    required this.fullText,
    required this.words,
  })  : wordStates = List.filled(words.length, WordState.hidden),
        isCompleted = false;
}

class MemorizeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // ── Setup State ──
  int _selectedSurahIndex = 0;
  int _startAyah = 1;
  int _endAyah = 7;
  int _totalAyahs = 7;

  // ── Session State ──
  List<VerseState> _verseStates = [];
  int _currentVerseIndex = 0;
  int _currentWordIndex = 0;
  bool _isLoading = false;
  String? _error;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _lastRecognizedText = '';

  // ── Getters ──
  int get selectedSurahIndex => _selectedSurahIndex;
  SurahInfo get selectedSurah => ReciteProvider.surahs[_selectedSurahIndex];
  int get startAyah => _startAyah;
  int get endAyah => _endAyah;
  int get totalAyahs => _totalAyahs;
  int get versesSelected => (_endAyah - _startAyah + 1).clamp(1, _totalAyahs);

  List<VerseState> get verseStates => _verseStates;
  int get currentVerseIndex => _currentVerseIndex;
  int get currentWordIndex => _currentWordIndex;
  VerseState? get currentVerse =>
      _verseStates.isNotEmpty ? _verseStates[_currentVerseIndex] : null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isListening => _isListening;
  bool get speechAvailable => _speechAvailable;
  String get lastRecognizedText => _lastRecognizedText;
  int get completedVerses =>
      _verseStates.where((v) => v.isCompleted).length;
  bool get isSessionComplete =>
      _verseStates.isNotEmpty && _verseStates.every((v) => v.isCompleted);

  // ── Setup Methods ──

  Future<void> selectSurah(int index) async {
    _selectedSurahIndex = index;
    final surah = ReciteProvider.surahs[index];
    _totalAyahs = surah.verseCount;
    _startAyah = 1;
    _endAyah = _totalAyahs;
    _error = null;
    notifyListeners();
  }

  void incrementStart() {
    if (_startAyah < _endAyah) {
      _startAyah++;
      notifyListeners();
    }
  }

  void decrementStart() {
    if (_startAyah > 1) {
      _startAyah--;
      notifyListeners();
    }
  }

  void incrementEnd() {
    if (_endAyah < _totalAyahs) {
      _endAyah++;
      notifyListeners();
    }
  }

  void decrementEnd() {
    if (_endAyah > _startAyah) {
      _endAyah--;
      notifyListeners();
    }
  }

  // ── Session Methods ──

  Future<void> startSession() async {
    _isLoading = true;
    _error = null;
    _verseStates = [];
    _currentVerseIndex = 0;
    _currentWordIndex = 0;
    notifyListeners();

    try {
      // Load all verses in range
      final allVerses = await _db.getSurahVerses(selectedSurah.number);
      final rangeVerses = allVerses.where((v) {
        final ayah = v['ayah'] as int? ?? 0;
        return ayah >= _startAyah && ayah <= _endAyah;
      }).toList();

      if (rangeVerses.isEmpty) {
        _error = 'No verses found in the selected range.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Build verse states
      bool bismillahSkipped = false;
      for (final verse in rangeVerses) {
        final text = (verse['text'] ?? '').toString().trim();
        int ayah = verse['ayah'] as int? ?? 0;

        // Skip Bismillah verse for ayah 1 (except Surah 9 which has no Bismillah)
        // Bismillah is NOT an ayah — it's just a decorative banner
        if (ayah == 1 && selectedSurah.number != 9) {
          if (text.startsWith('بِسۡمِ') ||
              text.startsWith('بِسْمِ') ||
              text.startsWith('بسم')) {
            bismillahSkipped = true;
            continue;
          }
        }

        // Renumber if Bismillah was skipped: ayah 2→1, 3→2, etc.
        if (bismillahSkipped) {
          ayah = ayah - 1;
        }

        final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        if (words.isNotEmpty) {
          _verseStates.add(VerseState(
            ayahNumber: ayah,
            fullText: text,
            words: words,
          ));
        }
      }

      // Mark first word as current
      if (_verseStates.isNotEmpty && _verseStates[0].words.isNotEmpty) {
        _verseStates[0].wordStates[0] = WordState.current;
      }

      // Initialize speech
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _error = 'Error loading verses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Speech Recognition ──

  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    if (!_speechAvailable) {
      _error = 'Speech recognition not available on this device.';
      notifyListeners();
      return;
    }

    _isListening = true;
    _lastRecognizedText = '';
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _lastRecognizedText = result.recognizedWords;
        _processRecognizedText(result.recognizedWords);
        notifyListeners();
      },
      localeId: 'ar', // Arabic locale
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  // ── Word Matching ──

  void _processRecognizedText(String recognizedText) {
    if (_verseStates.isEmpty || isSessionComplete) return;

    final verse = _verseStates[_currentVerseIndex];
    if (verse.isCompleted) return;

    final recognizedWords = recognizedText
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (recognizedWords.isEmpty) return;

    // Try to match recognized words against expected words starting from current position
    int matchIndex = _currentWordIndex;
    for (final spoken in recognizedWords) {
      if (matchIndex >= verse.words.length) break;

      final expected = verse.words[matchIndex];
      if (_wordsMatch(spoken, expected)) {
        verse.wordStates[matchIndex] = WordState.correct;
        matchIndex++;
      }
    }

    // Update current word index
    if (matchIndex > _currentWordIndex) {
      _currentWordIndex = matchIndex;

      // Mark next word as current (or complete verse)
      if (_currentWordIndex >= verse.words.length) {
        // All words matched — verse complete!
        verse.isCompleted = true;
        _advanceToNextVerse();
      } else {
        verse.wordStates[_currentWordIndex] = WordState.current;
      }
    }
  }

  bool _wordsMatch(String spoken, String expected) {
    final normalizedSpoken = _normalizeArabic(spoken);
    final normalizedExpected = _normalizeArabic(expected);

    if (normalizedSpoken == normalizedExpected) return true;

    // Fuzzy match: if first 2+ chars match and lengths are similar
    if (normalizedSpoken.length >= 2 && normalizedExpected.length >= 2) {
      final minLen = normalizedSpoken.length < normalizedExpected.length
          ? normalizedSpoken.length
          : normalizedExpected.length;
      final matchLen = minLen > 3 ? 3 : (minLen > 1 ? 2 : 1);

      if (normalizedSpoken.substring(0, matchLen) ==
          normalizedExpected.substring(0, matchLen)) {
        return true;
      }
    }

    // Check if spoken contains expected or vice versa
    if (normalizedSpoken.contains(normalizedExpected) ||
        normalizedExpected.contains(normalizedSpoken)) {
      return true;
    }

    return false;
  }

  /// Strip Arabic diacritics (tashkeel) for comparison
  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u06E1\u06DF]'), '') // tashkeel
        .replaceAll('ٱ', 'ا') // alef wasla
        .replaceAll('ۡ', '') // small sukun
        .replaceAll('ۢ', '') // small noon
        .replaceAll('ۥ', '') // small waw
        .replaceAll('ۦ', '') // small ya
        .trim();
  }

  void _advanceToNextVerse() {
    if (_currentVerseIndex < _verseStates.length - 1) {
      _currentVerseIndex++;
      _currentWordIndex = 0;
      // Mark first word of new verse as current
      if (_verseStates[_currentVerseIndex].words.isNotEmpty) {
        _verseStates[_currentVerseIndex].wordStates[0] = WordState.current;
      }
    }
    // If all verses complete, session is done
  }

  /// Skip current word (mark as mistake) and move to next
  void skipWord() {
    if (_verseStates.isEmpty || isSessionComplete) return;
    final verse = _verseStates[_currentVerseIndex];
    if (verse.isCompleted || _currentWordIndex >= verse.words.length) return;

    verse.wordStates[_currentWordIndex] = WordState.mistake;
    _currentWordIndex++;

    if (_currentWordIndex >= verse.words.length) {
      verse.isCompleted = true;
      _advanceToNextVerse();
    } else {
      verse.wordStates[_currentWordIndex] = WordState.current;
    }
    notifyListeners();
  }

  /// Reveal current word (mark as mistake since user couldn't recall)
  void revealCurrentWord() {
    if (_verseStates.isEmpty || isSessionComplete) return;
    final verse = _verseStates[_currentVerseIndex];
    if (verse.isCompleted || _currentWordIndex >= verse.words.length) return;

    verse.wordStates[_currentWordIndex] = WordState.mistake;
    _currentWordIndex++;

    if (_currentWordIndex >= verse.words.length) {
      verse.isCompleted = true;
      _advanceToNextVerse();
    } else {
      verse.wordStates[_currentWordIndex] = WordState.current;
    }
    notifyListeners();
  }

  /// Save memorization progress
  Future<void> saveProgress() async {
    try {
      final todayProgress = await _db.getTodayProgress();
      final currentMemorized =
          (todayProgress?['verses_memorized'] as int?) ?? 0;
      await _db.upsertProgress({
        'verses_memorized': currentMemorized + completedVerses,
      });

      await _db.logActivity(
        action: 'memorized_verse',
        description:
            'Memorized ${selectedSurah.name} : Ayah $_startAyah-$_endAyah ($completedVerses verses)',
        metadata: {
          'surah': selectedSurah.number,
          'start_ayah': _startAyah,
          'end_ayah': _endAyah,
          'completed': completedVerses,
        },
      );
    } catch (e) {
      _error = 'Error saving progress: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

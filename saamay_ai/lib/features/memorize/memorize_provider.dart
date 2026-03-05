import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../recite/recite_provider.dart';

class MemorizeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  int _selectedSurahIndex = 0; // index into ReciteProvider.surahs
  int _startAyah = 1;
  int _endAyah = 7; // Default for Al-Fatiha
  int _totalAyahs = 7;

  // Session state
  int _currentAyahIndex = 0; // index within the selected range
  Map<String, dynamic>? _currentVerse;
  bool _isVerseHidden = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get selectedSurahIndex => _selectedSurahIndex;
  SurahInfo get selectedSurah => ReciteProvider.surahs[_selectedSurahIndex];
  int get startAyah => _startAyah;
  int get endAyah => _endAyah;
  int get totalAyahs => _totalAyahs;
  int get versesSelected => (_endAyah - _startAyah + 1).clamp(1, _totalAyahs);
  int get currentAyahIndex => _currentAyahIndex;
  int get currentAyahNumber => _startAyah + _currentAyahIndex;
  Map<String, dynamic>? get currentVerse => _currentVerse;
  bool get isVerseHidden => _isVerseHidden;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFirstVerse => _currentAyahIndex == 0;
  bool get isLastVerse => _currentAyahIndex >= (versesSelected - 1);

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
    _currentAyahIndex = 0;
    _isVerseHidden = false;
    await _loadCurrentVerse();
  }

  Future<void> _loadCurrentVerse() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ayahNum = _startAyah + _currentAyahIndex;
      _currentVerse = await _db.getVerse(selectedSurah.number, ayahNum);
      if (_currentVerse == null) {
        _error = 'Verse not found. Please ensure quran_verses table is populated.';
      }
    } catch (e) {
      _error = 'Error loading verse: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleHideReveal() {
    _isVerseHidden = !_isVerseHidden;
    notifyListeners();
  }

  Future<void> nextVerse() async {
    if (!isLastVerse) {
      _currentAyahIndex++;
      _isVerseHidden = false;
      await _loadCurrentVerse();
    }
  }

  Future<void> previousVerse() async {
    if (!isFirstVerse) {
      _currentAyahIndex--;
      _isVerseHidden = false;
      await _loadCurrentVerse();
    }
  }

  Future<void> markAsMemorized() async {
    try {
      final todayProgress = await _db.getTodayProgress();
      final currentMemorized = (todayProgress?['verses_memorized'] as int?) ?? 0;
      await _db.upsertProgress({
        'verses_memorized': currentMemorized + 1,
      });

      await _db.logActivity(
        action: 'memorized_verse',
        description: 'Memorized ${selectedSurah.name} : $currentAyahNumber',
        metadata: {
          'surah': selectedSurah.number,
          'ayah': currentAyahNumber,
        },
      );
    } catch (e) {
      _error = 'Error saving progress: $e';
      notifyListeners();
    }
  }
}

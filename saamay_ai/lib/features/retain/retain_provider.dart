import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class RetainProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Random _random = Random();

  List<Map<String, dynamic>> _memorizedVerses = [];
  Map<String, dynamic>? _currentQuizVerse;
  bool _isVerseRevealed = false;
  bool _isLoading = false;
  String? _error;
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _totalAttempts = 0;

  List<Map<String, dynamic>> get memorizedVerses => _memorizedVerses;
  Map<String, dynamic>? get currentQuizVerse => _currentQuizVerse;
  bool get isVerseRevealed => _isVerseRevealed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get correctCount => _correctCount;
  int get incorrectCount => _incorrectCount;
  int get totalAttempts => _totalAttempts;
  double get successRate =>
      _totalAttempts > 0 ? (_correctCount / _totalAttempts) * 100 : 0;

  Future<void> loadMemorizedVerses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load some verses from the quran_verses table to practice with
      // In a full implementation, this would filter by memorized verses only
      final verses = await _db.getSurahVerses(1); // Start with Al-Fatiha
      if (verses.isEmpty) {
        // Try loading from a few surahs
        for (int s = 2; s <= 5; s++) {
          final moreVerses = await _db.getSurahVerses(s);
          verses.addAll(moreVerses);
          if (verses.length >= 20) break;
        }
      }
      _memorizedVerses = verses;
      if (_memorizedVerses.isNotEmpty) {
        _showNextVerse();
      } else {
        _error = 'No verses found. Please ensure quran_verses table is populated.';
      }
    } catch (e) {
      _error = 'Error loading verses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _showNextVerse() {
    if (_memorizedVerses.isEmpty) return;
    final index = _random.nextInt(_memorizedVerses.length);
    _currentQuizVerse = _memorizedVerses[index];
    _isVerseRevealed = false;
    notifyListeners();
  }

  void revealVerse() {
    _isVerseRevealed = true;
    notifyListeners();
  }

  Future<void> markCorrect() async {
    _correctCount++;
    _totalAttempts++;
    notifyListeners();

    try {
      final todayProgress = await _db.getTodayProgress();
      final currentCorrect = (todayProgress?['correct_recitations'] as int?) ?? 0;
      final currentSessions = (todayProgress?['practice_sessions'] as int?) ?? 0;
      await _db.upsertProgress({
        'correct_recitations': currentCorrect + 1,
        'practice_sessions': currentSessions + 1,
      });
    } catch (_) {}

    _showNextVerse();
  }

  Future<void> markIncorrect() async {
    _incorrectCount++;
    _totalAttempts++;
    notifyListeners();

    try {
      final todayProgress = await _db.getTodayProgress();
      final currentSessions = (todayProgress?['practice_sessions'] as int?) ?? 0;
      await _db.upsertProgress({
        'practice_sessions': currentSessions + 1,
      });
    } catch (_) {}

    _showNextVerse();
  }
}

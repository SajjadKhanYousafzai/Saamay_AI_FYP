import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/services/backend_service.dart';
import '../../core/services/database_service.dart';
import '../recite/recite_provider.dart';

/// Word-level state for retain quiz
enum RetainWordState { hidden, correct, mistake }

class RetainProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Random _random = Random();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Verse pool
  List<Map<String, dynamic>> _memorizedVerses = [];
  
  // Current quiz state
  Map<String, dynamic>? _currentQuizVerse;
  bool _isVerseRevealed = false;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isPlayingCorrection = false;
  String? _error;
  String _statusText = '';
  double? _lastAccuracy;
  
  // Word-level feedback
  List<String> _currentWords = [];
  List<RetainWordState> _wordStates = [];
  
  // Stats
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _totalAttempts = 0;
  
  // Surah/Ayah selection mode
  bool _isCustomMode = false;
  int _selectedSurahIndex = 0;
  int _selectedAyah = 1;

  String? _currentRecordPath;

  // ── Getters ──
  List<Map<String, dynamic>> get memorizedVerses => _memorizedVerses;
  Map<String, dynamic>? get currentQuizVerse => _currentQuizVerse;
  bool get isVerseRevealed => _isVerseRevealed;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isPlayingCorrection => _isPlayingCorrection;
  String? get error => _error;
  String get statusText => _statusText;
  double? get lastAccuracy => _lastAccuracy;
  List<String> get currentWords => _currentWords;
  List<RetainWordState> get wordStates => _wordStates;
  int get correctCount => _correctCount;
  int get incorrectCount => _incorrectCount;
  int get totalAttempts => _totalAttempts;
  double get successRate =>
      _totalAttempts > 0 ? (_correctCount / _totalAttempts) * 100 : 0;
  bool get isCustomMode => _isCustomMode;
  int get selectedSurahIndex => _selectedSurahIndex;
  int get selectedAyah => _selectedAyah;
  SurahInfo get selectedSurah => ReciteProvider.surahs[_selectedSurahIndex];

  // ── Load Random Verses ──
  Future<void> loadMemorizedVerses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load from multiple random surahs for variety
      final List<Map<String, dynamic>> allVerses = [];
      final usedSurahs = <int>{};
      
      // Pick 10 random surahs
      while (usedSurahs.length < 10 && usedSurahs.length < 114) {
        final surahNum = _random.nextInt(114) + 1;
        if (usedSurahs.contains(surahNum)) continue;
        usedSurahs.add(surahNum);
        
        try {
          final verses = await _db.getSurahVerses(surahNum);
          if (verses.isNotEmpty) {
            // Pick up to 3 random verses from each surah
            verses.shuffle(_random);
            allVerses.addAll(verses.take(3));
          }
        } catch (_) {}
      }

      _memorizedVerses = allVerses;
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

  // ── Load a Specific Surah/Ayah ──
  void setCustomMode(bool value) {
    _isCustomMode = value;
    notifyListeners();
  }

  void selectSurah(int index) {
    _selectedSurahIndex = index;
    _selectedAyah = 1;
    notifyListeners();
  }

  void selectAyah(int ayah) {
    _selectedAyah = ayah;
    notifyListeners();
  }

  Future<void> loadCustomVerse() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final surah = ReciteProvider.surahs[_selectedSurahIndex];
      final verses = await _db.getSurahVerses(surah.number);
      final match = verses.where((v) => v['ayah'] == _selectedAyah).toList();
      
      if (match.isNotEmpty) {
        _currentQuizVerse = match.first;
        _isVerseRevealed = false;
        _lastAccuracy = null;
        _statusText = '';
        _currentWords = [];
        _wordStates = [];
        _isCustomMode = false; // Go back to quiz view
      } else {
        _error = 'Verse not found.';
      }
    } catch (e) {
      _error = 'Error loading verse: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Navigation ──
  void _showNextVerse() {
    if (_memorizedVerses.isEmpty) return;
    final index = _random.nextInt(_memorizedVerses.length);
    _currentQuizVerse = _memorizedVerses[index];
    _isVerseRevealed = false;
    _lastAccuracy = null;
    _statusText = '';
    _currentWords = [];
    _wordStates = [];
    notifyListeners();
  }

  void nextVerse() => _showNextVerse();

  void revealVerse() {
    _isVerseRevealed = true;
    notifyListeners();
  }

  // ── Audio Recording ──
  Future<void> toggleRecording() async {
    if (_isListening) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      _error = 'Please grant microphone permissions.';
      notifyListeners();
      return;
    }

    if (_isPlayingCorrection) {
      await _audioPlayer.stop();
      _isPlayingCorrection = false;
    }

    _isListening = true;
    _statusText = 'Listening...';
    _error = null;
    _lastAccuracy = null;
    notifyListeners();

    try {
      final Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _currentRecordPath = '${tempDir.path}/retain_$timestamp.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentRecordPath!,
      );
    } catch (e) {
      _isListening = false;
      _error = 'Recording failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (!_isListening) return;

    try {
      final path = await _audioRecorder.stop();
      _isListening = false;
      _isProcessing = true;
      _statusText = 'Processing...';
      notifyListeners();

      if (path != null && File(path).existsSync()) {
        await _processRecording(File(path));
      } else {
        _error = 'Failed to locate recording.';
        _isProcessing = false;
        notifyListeners();
      }
    } catch (e) {
      _isListening = false;
      _isProcessing = false;
      _error = 'Stop recording failed: $e';
      notifyListeners();
    }
  }

  Future<void> _processRecording(File audioFile) async {
    if (_currentQuizVerse == null) return;

    final surahNum = _currentQuizVerse!['surah'] as int? ?? 1;
    final ayahNum = _currentQuizVerse!['ayah'] as int? ?? 1;

    try {
      final response = await BackendService.transcribeAudio(audioFile, surahNum, ayahNum);

      if (audioFile.existsSync()) audioFile.deleteSync();

      if (response['status'] == 'silence') {
        _statusText = 'No speech detected. Try again.';
        _isProcessing = false;
        notifyListeners();
        return;
      }

      if (response['status'] == 'success') {
        final analysis = response['analysis'] as Map<String, dynamic>?;

        if (analysis != null && analysis.containsKey('diff')) {
          final accuracy = (analysis['accuracy'] as num?)?.toDouble() ?? 0.0;
          _lastAccuracy = accuracy;
          _isVerseRevealed = true; // Show the verse after attempt

          // Build word states from diff
          final diffList = analysis['diff'] as List<dynamic>? ?? [];
          final text = (_currentQuizVerse!['text'] ?? '').toString().trim();
          final refWords = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
          
          _currentWords = refWords;
          _wordStates = List.filled(refWords.length, RetainWordState.hidden);
          
          int refIdx = 0;
          for (var d in diffList) {
            if (refIdx >= _wordStates.length) break;
            final status = d['status'] as String? ?? '';
            if (status == 'correct') {
              _wordStates[refIdx] = RetainWordState.correct;
              refIdx++;
            } else if (status == 'wrong' || status == 'missing') {
              _wordStates[refIdx] = RetainWordState.mistake;
              refIdx++;
            } else if (status == 'pending') {
              _wordStates[refIdx] = RetainWordState.mistake;
              refIdx++;
            }
          }

          _totalAttempts++;
          if (accuracy >= 80) {
            _correctCount++;
            _statusText = 'Excellent! ${accuracy.toStringAsFixed(0)}% accuracy';
          } else {
            _incorrectCount++;
            _statusText = '${accuracy.toStringAsFixed(0)}% — Playing correction...';
            _triggerCorrection(surahNum, ayahNum);
          }

          // Save progress
          try {
            final todayProgress = await _db.getTodayProgress();
            final currentCorrect = (todayProgress?['correct_recitations'] as int?) ?? 0;
            final currentSessions = (todayProgress?['practice_sessions'] as int?) ?? 0;
            await _db.upsertProgress({
              'correct_recitations': accuracy >= 80 ? currentCorrect + 1 : currentCorrect,
              'practice_sessions': currentSessions + 1,
            });
          } catch (_) {}
        } else {
          _statusText = 'Analysis failed.';
        }
      } else {
        _statusText = 'Transcription failed.';
      }
    } catch (e) {
      _error = 'Backend error: $e';
    }

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _triggerCorrection(int surahNum, int ayahNum) async {
    _isPlayingCorrection = true;
    notifyListeners();

    try {
      final audioUrl = BackendService.getAyahAudioUrl(surahNum, ayahNum);
      await _audioPlayer.play(UrlSource(audioUrl));
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlayingCorrection = false;
        notifyListeners();
      });
    } catch (e) {
      _isPlayingCorrection = false;
      notifyListeners();
    }
  }

  // ── Manual correct/incorrect (fallback) ──
  Future<void> markCorrect() async {
    _correctCount++;
    _totalAttempts++;
    notifyListeners();
    _showNextVerse();
  }

  Future<void> markIncorrect() async {
    _incorrectCount++;
    _totalAttempts++;
    notifyListeners();
    _showNextVerse();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

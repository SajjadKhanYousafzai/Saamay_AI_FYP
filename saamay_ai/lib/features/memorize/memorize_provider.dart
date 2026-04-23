import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/services/backend_service.dart';
import '../../core/services/database_service.dart';
import '../recite/recite_provider.dart';

/// State for each word in a verse
enum WordState { hidden, current, correct, mistake, pending }

/// Holds the state of a single verse during memorization
class VerseState {
  final int ayahNumber;
  final String fullText;
  final List<String> words;
  List<WordState> wordStates;
  bool isCompleted;
  double? lastAccuracy;

  VerseState({
    required this.ayahNumber,
    required this.fullText,
    required this.words,
  })  : wordStates = List.filled(words.length, WordState.hidden),
        isCompleted = false;
}

class MemorizeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer(); // For beep and correction

  // ── Setup State ──
  int _selectedSurahIndex = 0;
  int _startAyah = 1;
  int _endAyah = 7;
  int _totalAyahs = 7;

  // ── Session State ──
  List<VerseState> _verseStates = [];
  int _currentVerseIndex = 0;
  bool _isLoading = false;
  String? _error;
  bool _isListening = false;
  bool _isPlayingCorrection = false;
  String _lastRecognizedText = '';
  
  String? _currentRecordPath;

  // ── Getters ──
  int get selectedSurahIndex => _selectedSurahIndex;
  SurahInfo get selectedSurah => ReciteProvider.surahs[_selectedSurahIndex];
  int get startAyah => _startAyah;
  int get endAyah => _endAyah;
  int get totalAyahs => _totalAyahs;
  int get versesSelected => (_endAyah - _startAyah + 1).clamp(1, _totalAyahs);

  List<VerseState> get verseStates => _verseStates;
  int get currentVerseIndex => _currentVerseIndex;
  VerseState? get currentVerse =>
      _verseStates.isNotEmpty && _currentVerseIndex < _verseStates.length 
          ? _verseStates[_currentVerseIndex] 
          : null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isListening => _isListening;
  bool get isPlayingCorrection => _isPlayingCorrection;
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
        if (ayah == 1 && selectedSurah.number != 9) {
          if (text.startsWith('بِسۡمِ') ||
              text.startsWith('بِسْمِ') ||
              text.startsWith('بسم')) {
            bismillahSkipped = true;
            continue;
          }
        }

        // Renumber if Bismillah was skipped
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

      // Mark all words of the first verse as current originally
      // But now we just wait for audio transcription and the backend returns the diff!
      if (_verseStates.isNotEmpty) {
        _verseStates[0].wordStates = List.filled(_verseStates[0].words.length, WordState.current);
      }

      // Pre-load audio player
      _audioPlayer.onPlayerComplete.listen((event) {
        if (_isPlayingCorrection) {
          _isPlayingCorrection = false;
          notifyListeners();
        }
      });
      
    } catch (e) {
      _error = 'Error loading verses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Audio Recording ──

  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    // Check permission
    if (!await _audioRecorder.hasPermission()) {
      _error = 'Please grant microphone permissions to recite.';
      notifyListeners();
      return;
    }
    
    // Stop any playing correction audio
    if (_isPlayingCorrection) {
      await _audioPlayer.stop();
      _isPlayingCorrection = false;
    }

    _isListening = true;
    _lastRecognizedText = 'Listening...';
    _error = null;
    notifyListeners();

    try {
      final Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _currentRecordPath = '${tempDir.path}/recitation_$timestamp.wav';

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
      _error = 'Started recording failed: $e';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      final path = await _audioRecorder.stop();
      _isListening = false;
      _lastRecognizedText = 'Processing via Whisper...';
      notifyListeners();

      if (path != null && File(path).existsSync()) {
        await _processAudioFile(File(path));
      } else {
        _error = 'Failed to locate recording.';
        notifyListeners();
      }
    } catch (e) {
      _isListening = false;
      _error = 'Stopped recording failed: $e';
      notifyListeners();
    }
  }

  // ── Backend Processing ──

  Future<void> _processAudioFile(File audioFile) async {
    if (_verseStates.isEmpty || isSessionComplete) return;

    final currentSurahNum = selectedSurah.number;
    final currentAyahNum = currentVerse!.ayahNumber;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await BackendService.transcribeAudio(
        audioFile, 
        currentSurahNum, 
        currentAyahNum,
      );

      // Clean up temp recording file
      if (audioFile.existsSync()) {
        audioFile.deleteSync();
      }

      if (response['status'] == 'silence') {
        _lastRecognizedText = 'No speech detected.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (response['status'] == 'success') {
        _lastRecognizedText = response['transcription'] ?? '';
        final analysis = response['analysis'] as Map<String, dynamic>?;

        if (analysis != null && analysis.containsKey('diff')) {
          _updateVerseFromDiff(analysis);
        } else {
          _error = 'Analysis failed to return word data.';
        }
      } else {
        _error = 'Transcription failed on server.';
      }

    } catch (e) {
      _error = 'Failed to connect to backend: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _updateVerseFromDiff(Map<String, dynamic> analysis) {
    if (_currentVerseIndex >= _verseStates.length) return;
    
    final verse = _verseStates[_currentVerseIndex];
    final accuracy = (analysis['accuracy'] as num?)?.toDouble() ?? 0.0;
    verse.lastAccuracy = accuracy;
    
    final diffList = analysis['diff'] as List<dynamic>? ?? [];
    
    // Map backend diff to our WordState
    // Background info: backend diff has "correct", "wrong" (replace), "missing" (delete), "extra" (insert), "pending" (trailing delete)
    // We update the wordStates for the reference words only (since our UI shows reference words)
    int refWordIndex = 0;
    for (var d in diffList) {
      if (refWordIndex >= verse.wordStates.length) break;
      
      final String status = d['status'] as String? ?? '';
      
      if (status == 'correct') {
        verse.wordStates[refWordIndex] = WordState.correct;
        refWordIndex++;
      } else if (status == 'wrong') {
        verse.wordStates[refWordIndex] = WordState.mistake;
        refWordIndex++;
      } else if (status == 'missing') {
        verse.wordStates[refWordIndex] = WordState.mistake; // user missed it, count as mistake
        refWordIndex++;
      } else if (status == 'pending') {
        verse.wordStates[refWordIndex] = WordState.hidden; // not spoken yet
        refWordIndex++;
      }
      // if 'extra', the user added words, but our UI only displays reference words, so we ignore mapping.
    }
    
    // Check if the verse is completely recited with no pending verbs and high accuracy
    bool hasPending = verse.wordStates.any((s) => s == WordState.hidden);
    
    if (!hasPending) {
      verse.isCompleted = true;
      if (accuracy < 80.0) {
        _triggerCorrection(accuracy);
      } else {
        _advanceToNextVerse();
      }
    }
    
    notifyListeners();
  }

  Future<void> _triggerCorrection(double accuracy) async {
    _isPlayingCorrection = true;
    notifyListeners();
    
    try {
      // Play a short error beep first (you could put a local asset beep.mp3 here)
      // Since we don't have a guaranteed beep asset, we'll just immediately play the correct audio.
      final currentSurahNum = selectedSurah.number;
      final currentAyahNum = currentVerse!.ayahNumber;
      final audioUrl = BackendService.getAyahAudioUrl(currentSurahNum, currentAyahNum);
      
      await _audioPlayer.play(UrlSource(audioUrl));
      
      // We don't advance the verse until they try again or manually skip?
      // For now, let the user re-record. The verse stays as currentVerseIndex.
      
    } catch (e) {
      _error = 'Failed to load correction audio.';
      _isPlayingCorrection = false;
      notifyListeners();
    }
  }

  void _advanceToNextVerse() {
    if (_currentVerseIndex < _verseStates.length - 1) {
      _currentVerseIndex++;
      // Mark words of the next verse as hidden, but maybe set the whole thing as "current" waiting
      for (int i=0; i < _verseStates[_currentVerseIndex].wordStates.length; i++) {
        _verseStates[_currentVerseIndex].wordStates[i] = WordState.hidden;
      }
    } else {
      // Session done
      notifyListeners();
    }
  }

  /// Skip current verse completely (manual bypass)
  void skipVerse() {
    if (_verseStates.isEmpty || isSessionComplete) return;
    
    final verse = _verseStates[_currentVerseIndex];
    verse.isCompleted = true;
    for (int i=0; i<verse.wordStates.length; i++) {
      if (verse.wordStates[i] == WordState.hidden) {
        verse.wordStates[i] = WordState.mistake; // label skipped as mistake
      }
    }
    
    _advanceToNextVerse();
    notifyListeners();
  }

  /// Manually force reveal remaining of the current verse
  void revealCurrentVerse() {
    if (_verseStates.isEmpty || isSessionComplete) return;
    final verse = _verseStates[_currentVerseIndex];
    if (verse.isCompleted) return;

    for (int i=0; i<verse.wordStates.length; i++) {
      if (verse.wordStates[i] == WordState.hidden) {
         verse.wordStates[i] = WordState.mistake; // Revealed words are marked as mistake
      }
    }
    verse.isCompleted = true;
    
    if (verse.lastAccuracy == null || verse.lastAccuracy! < 80) {
      _triggerCorrection(verse.lastAccuracy ?? 0.0);
    } else {
      _advanceToNextVerse();
      notifyListeners();
    }
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
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

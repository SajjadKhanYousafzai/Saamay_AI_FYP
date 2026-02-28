import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class MemorizeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  int _selectedSurah = 1;
  int _selectedAyah = 1;
  int _totalAyahs = 7; // Default for Al-Fatiha
  Map<String, dynamic>? _currentVerse;
  bool _isVerseHidden = false;
  bool _isLoading = false;
  String? _error;

  int get selectedSurah => _selectedSurah;
  int get selectedAyah => _selectedAyah;
  int get totalAyahs => _totalAyahs;
  Map<String, dynamic>? get currentVerse => _currentVerse;
  bool get isVerseHidden => _isVerseHidden;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Surah names list
  static const List<String> surahNames = [
    'Al-Fatiha', 'Al-Baqarah', 'Aal-Imran', 'An-Nisa', 'Al-Ma\'idah',
    'Al-An\'am', 'Al-A\'raf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Taha',
    'Al-Anbya', 'Al-Hajj', 'Al-Mu\'minun', 'An-Nur', 'Al-Furqan',
    'Ash-Shu\'ara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqi\'ah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saf', 'Al-Jumu\'ah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Ma\'arij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Nazi\'at', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-A\'la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duhaa', 'Ash-Sharh', 'At-Tin',
    'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
    'Al-Qari\'ah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil',
    'Quraysh', 'Al-Ma\'un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  Future<void> selectSurah(int surah) async {
    _selectedSurah = surah;
    _selectedAyah = 1;
    _isVerseHidden = false;
    _error = null;
    notifyListeners();

    // Get ayah count for this surah
    _totalAyahs = await _db.getAyahCount(surah);
    if (_totalAyahs == 0) _totalAyahs = 7; // fallback
    notifyListeners();

    await loadVerse();
  }

  Future<void> selectAyah(int ayah) async {
    _selectedAyah = ayah;
    _isVerseHidden = false;
    notifyListeners();
    await loadVerse();
  }

  Future<void> loadVerse() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentVerse = await _db.getVerse(_selectedSurah, _selectedAyah);
      if (_currentVerse == null) {
        _error = 'Verse not found in database. Please ensure quran_verses table is populated.';
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

  Future<void> markAsMemorized() async {
    try {
      // Update user progress
      final todayProgress = await _db.getTodayProgress();
      final currentMemorized = (todayProgress?['verses_memorized'] as int?) ?? 0;
      await _db.upsertProgress({
        'verses_memorized': currentMemorized + 1,
      });

      // Log activity
      await _db.logActivity(
        action: 'memorized_verse',
        description: 'Memorized ${surahNames[_selectedSurah - 1]} : $_selectedAyah',
        metadata: {
          'surah': _selectedSurah,
          'ayah': _selectedAyah,
        },
      );
    } catch (e) {
      _error = 'Error saving progress: $e';
      notifyListeners();
    }
  }
}

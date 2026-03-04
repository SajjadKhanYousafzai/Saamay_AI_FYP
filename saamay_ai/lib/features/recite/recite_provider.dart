import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class ReciteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // ── Surah metadata (static Quran data) ──
  static const List<SurahInfo> surahs = [
    SurahInfo(1, 'Al-Fatihah', 'الفاتحة', 'The Opening', 'Meccan', 7),
    SurahInfo(2, 'Al-Baqarah', 'البقرة', 'The Cow', 'Medinan', 286),
    SurahInfo(3, 'Aal-Imran', 'آل عمران', 'The Family of Imran', 'Medinan', 200),
    SurahInfo(4, 'An-Nisa', 'النساء', 'The Women', 'Medinan', 176),
    SurahInfo(5, 'Al-Maidah', 'المائدة', 'The Table Spread', 'Medinan', 120),
    SurahInfo(6, 'Al-Anam', 'الأنعام', 'The Cattle', 'Meccan', 165),
    SurahInfo(7, 'Al-Araf', 'الأعراف', 'The Heights', 'Meccan', 206),
    SurahInfo(8, 'Al-Anfal', 'الأنفال', 'The Spoils of War', 'Medinan', 75),
    SurahInfo(9, 'At-Tawbah', 'التوبة', 'The Repentance', 'Medinan', 129),
    SurahInfo(10, 'Yunus', 'يونس', 'Jonah', 'Meccan', 109),
    SurahInfo(11, 'Hud', 'هود', 'Hud', 'Meccan', 123),
    SurahInfo(12, 'Yusuf', 'يوسف', 'Joseph', 'Meccan', 111),
    SurahInfo(13, 'Ar-Rad', 'الرعد', 'The Thunder', 'Medinan', 43),
    SurahInfo(14, 'Ibrahim', 'إبراهيم', 'Abraham', 'Meccan', 52),
    SurahInfo(15, 'Al-Hijr', 'الحجر', 'The Rocky Tract', 'Meccan', 99),
    SurahInfo(16, 'An-Nahl', 'النحل', 'The Bee', 'Meccan', 128),
    SurahInfo(17, 'Al-Isra', 'الإسراء', 'The Night Journey', 'Meccan', 111),
    SurahInfo(18, 'Al-Kahf', 'الكهف', 'The Cave', 'Meccan', 110),
    SurahInfo(19, 'Maryam', 'مريم', 'Mary', 'Meccan', 98),
    SurahInfo(20, 'Taha', 'طه', 'Ta-Ha', 'Meccan', 135),
    SurahInfo(21, 'Al-Anbya', 'الأنبياء', 'The Prophets', 'Meccan', 112),
    SurahInfo(22, 'Al-Hajj', 'الحج', 'The Pilgrimage', 'Medinan', 78),
    SurahInfo(23, 'Al-Muminun', 'المؤمنون', 'The Believers', 'Meccan', 118),
    SurahInfo(24, 'An-Nur', 'النور', 'The Light', 'Medinan', 64),
    SurahInfo(25, 'Al-Furqan', 'الفرقان', 'The Criterion', 'Meccan', 77),
    SurahInfo(26, 'Ash-Shuara', 'الشعراء', 'The Poets', 'Meccan', 227),
    SurahInfo(27, 'An-Naml', 'النمل', 'The Ants', 'Meccan', 93),
    SurahInfo(28, 'Al-Qasas', 'القصص', 'The Stories', 'Meccan', 88),
    SurahInfo(29, 'Al-Ankabut', 'العنكبوت', 'The Spider', 'Meccan', 69),
    SurahInfo(30, 'Ar-Rum', 'الروم', 'The Romans', 'Meccan', 60),
    SurahInfo(31, 'Luqman', 'لقمان', 'Luqman', 'Meccan', 34),
    SurahInfo(32, 'As-Sajdah', 'السجدة', 'The Prostration', 'Meccan', 30),
    SurahInfo(33, 'Al-Ahzab', 'الأحزاب', 'The Combined Forces', 'Medinan', 73),
    SurahInfo(34, 'Saba', 'سبأ', 'Sheba', 'Meccan', 54),
    SurahInfo(35, 'Fatir', 'فاطر', 'The Originator', 'Meccan', 45),
    SurahInfo(36, 'Ya-Sin', 'يس', 'Ya-Sin', 'Meccan', 83),
    SurahInfo(37, 'As-Saffat', 'الصافات', 'Those Ranged in Ranks', 'Meccan', 182),
    SurahInfo(38, 'Sad', 'ص', 'Sad', 'Meccan', 88),
    SurahInfo(39, 'Az-Zumar', 'الزمر', 'The Groups', 'Meccan', 75),
    SurahInfo(40, 'Ghafir', 'غافر', 'The Forgiver', 'Meccan', 85),
    SurahInfo(41, 'Fussilat', 'فصلت', 'Explained in Detail', 'Meccan', 54),
    SurahInfo(42, 'Ash-Shura', 'الشورى', 'The Consultation', 'Meccan', 53),
    SurahInfo(43, 'Az-Zukhruf', 'الزخرف', 'The Gold Adornments', 'Meccan', 89),
    SurahInfo(44, 'Ad-Dukhan', 'الدخان', 'The Smoke', 'Meccan', 59),
    SurahInfo(45, 'Al-Jathiyah', 'الجاثية', 'The Kneeling', 'Meccan', 37),
    SurahInfo(46, 'Al-Ahqaf', 'الأحقاف', 'The Wind-Curved Sandhills', 'Meccan', 35),
    SurahInfo(47, 'Muhammad', 'محمد', 'Muhammad', 'Medinan', 38),
    SurahInfo(48, 'Al-Fath', 'الفتح', 'The Victory', 'Medinan', 29),
    SurahInfo(49, 'Al-Hujurat', 'الحجرات', 'The Rooms', 'Medinan', 18),
    SurahInfo(50, 'Qaf', 'ق', 'Qaf', 'Meccan', 45),
    SurahInfo(51, 'Adh-Dhariyat', 'الذاريات', 'The Winnowing Winds', 'Meccan', 60),
    SurahInfo(52, 'At-Tur', 'الطور', 'The Mount', 'Meccan', 49),
    SurahInfo(53, 'An-Najm', 'النجم', 'The Star', 'Meccan', 62),
    SurahInfo(54, 'Al-Qamar', 'القمر', 'The Moon', 'Meccan', 55),
    SurahInfo(55, 'Ar-Rahman', 'الرحمن', 'The Most Merciful', 'Medinan', 78),
    SurahInfo(56, 'Al-Waqiah', 'الواقعة', 'The Inevitable', 'Meccan', 96),
    SurahInfo(57, 'Al-Hadid', 'الحديد', 'The Iron', 'Medinan', 29),
    SurahInfo(58, 'Al-Mujadila', 'المجادلة', 'The Pleading Woman', 'Medinan', 22),
    SurahInfo(59, 'Al-Hashr', 'الحشر', 'The Exile', 'Medinan', 24),
    SurahInfo(60, 'Al-Mumtahanah', 'الممتحنة', 'She That is Examined', 'Medinan', 13),
    SurahInfo(61, 'As-Saf', 'الصف', 'The Ranks', 'Medinan', 14),
    SurahInfo(62, 'Al-Jumuah', 'الجمعة', 'Friday', 'Medinan', 11),
    SurahInfo(63, 'Al-Munafiqun', 'المنافقون', 'The Hypocrites', 'Medinan', 11),
    SurahInfo(64, 'At-Taghabun', 'التغابن', 'The Mutual Disillusion', 'Medinan', 18),
    SurahInfo(65, 'At-Talaq', 'الطلاق', 'The Divorce', 'Medinan', 12),
    SurahInfo(66, 'At-Tahrim', 'التحريم', 'The Prohibition', 'Medinan', 12),
    SurahInfo(67, 'Al-Mulk', 'الملك', 'The Sovereignty', 'Meccan', 30),
    SurahInfo(68, 'Al-Qalam', 'القلم', 'The Pen', 'Meccan', 52),
    SurahInfo(69, 'Al-Haqqah', 'الحاقة', 'The Reality', 'Meccan', 52),
    SurahInfo(70, 'Al-Maarij', 'المعارج', 'The Ascending Stairways', 'Meccan', 44),
    SurahInfo(71, 'Nuh', 'نوح', 'Noah', 'Meccan', 28),
    SurahInfo(72, 'Al-Jinn', 'الجن', 'The Jinn', 'Meccan', 28),
    SurahInfo(73, 'Al-Muzzammil', 'المزمل', 'The Enshrouded One', 'Meccan', 20),
    SurahInfo(74, 'Al-Muddaththir', 'المدثر', 'The Cloaked One', 'Meccan', 56),
    SurahInfo(75, 'Al-Qiyamah', 'القيامة', 'The Resurrection', 'Meccan', 40),
    SurahInfo(76, 'Al-Insan', 'الإنسان', 'Man', 'Medinan', 31),
    SurahInfo(77, 'Al-Mursalat', 'المرسلات', 'The Emissaries', 'Meccan', 50),
    SurahInfo(78, 'An-Naba', 'النبأ', 'The Tidings', 'Meccan', 40),
    SurahInfo(79, 'An-Naziat', 'النازعات', 'Those Who Drag Forth', 'Meccan', 46),
    SurahInfo(80, 'Abasa', 'عبس', 'He Frowned', 'Meccan', 42),
    SurahInfo(81, 'At-Takwir', 'التكوير', 'The Overthrowing', 'Meccan', 29),
    SurahInfo(82, 'Al-Infitar', 'الانفطار', 'The Cleaving', 'Meccan', 19),
    SurahInfo(83, 'Al-Mutaffifin', 'المطففين', 'The Defrauding', 'Meccan', 36),
    SurahInfo(84, 'Al-Inshiqaq', 'الانشقاق', 'The Sundering', 'Meccan', 25),
    SurahInfo(85, 'Al-Buruj', 'البروج', 'The Great Stars', 'Meccan', 22),
    SurahInfo(86, 'At-Tariq', 'الطارق', 'The Morning Star', 'Meccan', 17),
    SurahInfo(87, 'Al-Ala', 'الأعلى', 'The Most High', 'Meccan', 19),
    SurahInfo(88, 'Al-Ghashiyah', 'الغاشية', 'The Overwhelming', 'Meccan', 26),
    SurahInfo(89, 'Al-Fajr', 'الفجر', 'The Dawn', 'Meccan', 30),
    SurahInfo(90, 'Al-Balad', 'البلد', 'The City', 'Meccan', 20),
    SurahInfo(91, 'Ash-Shams', 'الشمس', 'The Sun', 'Meccan', 15),
    SurahInfo(92, 'Al-Layl', 'الليل', 'The Night', 'Meccan', 21),
    SurahInfo(93, 'Ad-Duhaa', 'الضحى', 'The Morning Hours', 'Meccan', 11),
    SurahInfo(94, 'Ash-Sharh', 'الشرح', 'The Relief', 'Meccan', 8),
    SurahInfo(95, 'At-Tin', 'التين', 'The Fig', 'Meccan', 8),
    SurahInfo(96, 'Al-Alaq', 'العلق', 'The Clot', 'Meccan', 19),
    SurahInfo(97, 'Al-Qadr', 'القدر', 'The Power', 'Meccan', 5),
    SurahInfo(98, 'Al-Bayyinah', 'البينة', 'The Clear Proof', 'Medinan', 8),
    SurahInfo(99, 'Az-Zalzalah', 'الزلزلة', 'The Earthquake', 'Medinan', 8),
    SurahInfo(100, 'Al-Adiyat', 'العاديات', 'The Courser', 'Meccan', 11),
    SurahInfo(101, 'Al-Qariah', 'القارعة', 'The Calamity', 'Meccan', 11),
    SurahInfo(102, 'At-Takathur', 'التكاثر', 'The Rivalry', 'Meccan', 8),
    SurahInfo(103, 'Al-Asr', 'العصر', 'The Declining Day', 'Meccan', 3),
    SurahInfo(104, 'Al-Humazah', 'الهمزة', 'The Traducer', 'Meccan', 9),
    SurahInfo(105, 'Al-Fil', 'الفيل', 'The Elephant', 'Meccan', 5),
    SurahInfo(106, 'Quraysh', 'قريش', 'Quraysh', 'Meccan', 4),
    SurahInfo(107, 'Al-Maun', 'الماعون', 'The Small Kindnesses', 'Meccan', 7),
    SurahInfo(108, 'Al-Kawthar', 'الكوثر', 'The Abundance', 'Meccan', 3),
    SurahInfo(109, 'Al-Kafirun', 'الكافرون', 'The Disbelievers', 'Meccan', 6),
    SurahInfo(110, 'An-Nasr', 'النصر', 'The Divine Support', 'Medinan', 3),
    SurahInfo(111, 'Al-Masad', 'المسد', 'The Palm Fiber', 'Meccan', 5),
    SurahInfo(112, 'Al-Ikhlas', 'الإخلاص', 'The Sincerity', 'Meccan', 4),
    SurahInfo(113, 'Al-Falaq', 'الفلق', 'The Daybreak', 'Meccan', 5),
    SurahInfo(114, 'An-Nas', 'الناس', 'Mankind', 'Meccan', 6),
  ];

  // ── Para (Juz) metadata ──
  static const List<ParaInfo> paras = [
    ParaInfo(1, 'Alif Lam Mim', 'الم', 'Al-Baqarah 1', 148),
    ParaInfo(2, 'Sayaqool', 'سيقول', 'Al-Baqarah 142', 111),
    ParaInfo(3, 'Tilkal Rusul', 'تلك الرسل', 'Al-Baqarah 253', 126),
    ParaInfo(4, 'Lan Tanaloo', 'لن تنالوا', 'Aal-Imran 93', 131),
    ParaInfo(5, 'Wal Muhsanat', 'والمحصنات', 'An-Nisa 24', 124),
    ParaInfo(6, 'La Yuhibbullah', 'لا يحب الله', 'An-Nisa 148', 110),
    ParaInfo(7, 'Wa Iza Samiu', 'وإذا سمعوا', 'Al-Maidah 83', 149),
    ParaInfo(8, 'Wa Lau Annana', 'ولو أننا', 'Al-Anam 111', 142),
    ParaInfo(9, 'Qal al-Mala', 'قال الملأ', 'Al-Araf 88', 159),
    ParaInfo(10, 'Wa A\'lamu', 'واعلموا', 'Al-Anfal 41', 127),
    ParaInfo(11, 'Yatazeroon', 'يعتذرون', 'At-Tawbah 93', 151),
    ParaInfo(12, 'Wa Ma Min Dabbah', 'وما من دابة', 'Hud 6', 110),
    ParaInfo(13, 'Wa Ma Ubarri\'u', 'وما أبرئ', 'Yusuf 53', 154),
    ParaInfo(14, 'Rubama', 'ربما', 'Al-Hijr 1', 227),
    ParaInfo(15, 'Subhan Alladhi', 'سبحان الذي', 'Al-Isra 1', 185),
    ParaInfo(16, 'Qal Alam', 'قال ألم', 'Al-Kahf 75', 269),
    ParaInfo(17, 'Iqtaraba', 'اقترب', 'Al-Anbya 1', 190),
    ParaInfo(18, 'Qad Aflaha', 'قد أفلح', 'Al-Muminun 1', 202),
    ParaInfo(19, 'Wa Qal Alladhina', 'وقال الذين', 'Al-Furqan 21', 339),
    ParaInfo(20, 'A\'man Khalaq', 'أمن خلق', 'An-Naml 56', 171),
    ParaInfo(21, 'Utlu Ma Uhiya', 'اتل ما أوحي', 'Al-Ankabut 46', 178),
    ParaInfo(22, 'Wa Man Yaqnut', 'ومن يقنت', 'Al-Ahzab 31', 169),
    ParaInfo(23, 'Wa Mali', 'وما لي', 'Ya-Sin 22', 357),
    ParaInfo(24, 'Fa Man Azlamu', 'فمن أظلم', 'Az-Zumar 32', 175),
    ParaInfo(25, 'Ilayhi Yuraddu', 'إليه يرد', 'Fussilat 47', 246),
    ParaInfo(26, 'Ha Mim', 'حم', 'Al-Ahqaf 1', 195),
    ParaInfo(27, 'Qala Fa Ma Khatbukum', 'قال فما خطبكم', 'Adh-Dhariyat 31', 399),
    ParaInfo(28, 'Qad Sami\'a', 'قد سمع', 'Al-Mujadila 1', 137),
    ParaInfo(29, 'Tabarakalladhi', 'تبارك الذي', 'Al-Mulk 1', 431),
    ParaInfo(30, 'Amma Yatasa\'aloon', 'عمّ يتساءلون', 'An-Naba 1', 564),
  ];

  // ── State ──
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = false;
  String? _error;
  String _translationLang = 'en'; // 'en', 'ur', 'none'

  List<Map<String, dynamic>> get verses => _verses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get translationLang => _translationLang;

  void setTranslationLang(String lang) {
    _translationLang = lang;
    notifyListeners();
  }

  Future<void> loadSurahVerses(int surahNumber) async {
    _isLoading = true;
    _error = null;
    _verses = [];
    notifyListeners();

    try {
      _verses = await _db.getSurahVerses(surahNumber);
      if (_verses.isEmpty) {
        _error = 'No verses found. Please ensure quran_verses table is populated.';
      }
    } catch (e) {
      _error = 'Error loading verses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadJuzVerses(int juzNumber) async {
    _isLoading = true;
    _error = null;
    _verses = [];
    notifyListeners();

    try {
      _verses = await _db.getJuzVerses(juzNumber);
      if (_verses.isEmpty) {
        _error = 'No verses found for this Para.';
      }
    } catch (e) {
      _error = 'Error loading verses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordRecitation(int surahNumber, int ayahNumber) async {
    try {
      final todayProgress = await _db.getTodayProgress();
      final currentRecitations = (todayProgress?['total_recitations'] as int?) ?? 0;
      await _db.upsertProgress({
        'total_recitations': currentRecitations + 1,
      });
      await _db.logActivity(
        action: 'recitation',
        description: 'Recited Surah $surahNumber : $ayahNumber',
      );
    } catch (e) {
      // silently fail
    }
  }
}

class SurahInfo {
  final int number;
  final String name;
  final String arabicName;
  final String englishMeaning;
  final String type; // 'Meccan' or 'Medinan'
  final int verseCount;

  const SurahInfo(
    this.number,
    this.name,
    this.arabicName,
    this.englishMeaning,
    this.type,
    this.verseCount,
  );
}

class ParaInfo {
  final int number;
  final String name;
  final String arabicName;
  final String startingSurah;
  final int totalVerses;

  const ParaInfo(
    this.number,
    this.name,
    this.arabicName,
    this.startingSurah,
    this.totalVerses,
  );
}

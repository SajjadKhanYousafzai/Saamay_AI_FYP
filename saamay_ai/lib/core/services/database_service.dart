import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../constants/app_strings.dart';

class DatabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  String? get _userId => _client.auth.currentUser?.id;

  // ── Profiles ──

  Future<Map<String, dynamic>?> getProfile() async {
    if (_userId == null) return null;
    final response = await _client
        .from(AppStrings.tableProfiles)
        .select()
        .eq('id', _userId!)
        .maybeSingle();
    return response;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_userId == null) return;
    await _client
        .from(AppStrings.tableProfiles)
        .update(data)
        .eq('id', _userId!);
  }

  // ── User Settings ──

  Future<Map<String, dynamic>?> getUserSettings() async {
    if (_userId == null) return null;
    final response = await _client
        .from(AppStrings.tableUserSettings)
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();
    return response;
  }

  Future<void> upsertUserSettings(Map<String, dynamic> data) async {
    if (_userId == null) return;
    data['user_id'] = _userId;
    await _client.from(AppStrings.tableUserSettings).upsert(data);
  }

  // ── Quran Verses ──

  Future<List<Map<String, dynamic>>> getSurahVerses(int surahNumber) async {
    final response = await _client
        .from(AppStrings.tableQuranVerses)
        .select()
        .eq('surah', surahNumber)
        .order('ayah', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Juz boundaries: [startSurah, startAyah, endSurah, endAyah]
  static const List<List<int>> _juzBoundaries = [
    [1, 1, 2, 141],      // Juz 1
    [2, 142, 2, 252],     // Juz 2
    [2, 253, 3, 92],      // Juz 3
    [3, 93, 4, 23],       // Juz 4
    [4, 24, 4, 147],      // Juz 5
    [4, 148, 5, 81],      // Juz 6
    [5, 82, 6, 110],      // Juz 7
    [6, 111, 7, 87],      // Juz 8
    [7, 88, 8, 40],       // Juz 9
    [8, 41, 9, 92],       // Juz 10
    [9, 93, 11, 5],       // Juz 11
    [11, 6, 12, 52],      // Juz 12
    [12, 53, 14, 52],     // Juz 13
    [15, 1, 16, 128],     // Juz 14
    [17, 1, 18, 74],      // Juz 15
    [18, 75, 20, 135],    // Juz 16
    [21, 1, 22, 78],      // Juz 17
    [23, 1, 25, 20],      // Juz 18
    [25, 21, 27, 55],     // Juz 19
    [27, 56, 29, 45],     // Juz 20
    [29, 46, 33, 30],     // Juz 21
    [33, 31, 36, 27],     // Juz 22
    [36, 28, 39, 31],     // Juz 23
    [39, 32, 41, 46],     // Juz 24
    [41, 47, 45, 37],     // Juz 25
    [46, 1, 51, 30],      // Juz 26
    [51, 31, 57, 29],     // Juz 27
    [58, 1, 66, 12],      // Juz 28
    [67, 1, 77, 50],      // Juz 29
    [78, 1, 114, 6],      // Juz 30
  ];

  Future<List<Map<String, dynamic>>> getJuzVerses(int juzNumber) async {
    if (juzNumber < 1 || juzNumber > 30) return [];
    final b = _juzBoundaries[juzNumber - 1];
    final startSurah = b[0], startAyah = b[1], endSurah = b[2], endAyah = b[3];

    String filter;
    if (startSurah == endSurah) {
      // Same surah — simple range
      filter = 'and(surah.eq.$startSurah,ayah.gte.$startAyah,ayah.lte.$endAyah)';
    } else {
      List<String> conditions = [];
      // Start surah (partial — from startAyah to end)
      conditions.add('and(surah.eq.$startSurah,ayah.gte.$startAyah)');
      // Middle surahs (fully included)
      if (endSurah - startSurah > 1) {
        conditions.add('and(surah.gt.$startSurah,surah.lt.$endSurah)');
      }
      // End surah (partial — from 1 to endAyah)
      conditions.add('and(surah.eq.$endSurah,ayah.lte.$endAyah)');
      filter = conditions.join(',');
    }

    final response = await _client
        .from(AppStrings.tableQuranVerses)
        .select()
        .or(filter)
        .order('surah', ascending: true)
        .order('ayah', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getVerse(int surah, int ayah) async {
    final response = await _client
        .from(AppStrings.tableQuranVerses)
        .select()
        .eq('surah', surah)
        .eq('ayah', ayah)
        .maybeSingle();
    return response;
  }

  Future<int> getSurahCount() async {
    // Quran has 114 surahs
    return 114;
  }

  Future<int> getAyahCount(int surahNumber) async {
    final response = await _client
        .from(AppStrings.tableQuranVerses)
        .select('ayah')
        .eq('surah', surahNumber)
        .order('ayah', ascending: false)
        .limit(1)
        .maybeSingle();
    return response?['ayah'] ?? 0;
  }

  // ── Bookmark Collections ──

  Future<List<Map<String, dynamic>>> getBookmarkFolders() async {
    if (_userId == null) return [];
    final response = await _client
        .from('bookmark_collections')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createBookmarkFolder(String name) async {
    if (_userId == null) return null;
    final response = await _client.from('bookmark_collections').insert({
      'user_id': _userId,
      'name': name,
    }).select().maybeSingle();
    return response;
  }

  Future<void> deleteBookmarkFolder(String folderId) async {
    await _client.from('bookmark_collections').delete().eq('id', folderId);
  }

  // ── Bookmarks ──

  Future<List<Map<String, dynamic>>> getBookmarks({String? folderId}) async {
    if (_userId == null) return [];
    
    var query = _client
        .from(AppStrings.tableBookmarks)
        .select()
        .eq('user_id', _userId!);
        
    if (folderId != null) {
      query = query.eq('collection_id', folderId);
    } else {
      query = query.isFilter('collection_id', null);
    }
    
    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? ayahText,
    String? folderId,
  }) async {
    if (_userId == null) return;
    await _client.from(AppStrings.tableBookmarks).upsert({
      'user_id': _userId,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'surah_name': surahName,
      'ayah_text': ayahText,
      if (folderId != null) 'collection_id': folderId,
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _client
        .from(AppStrings.tableBookmarks)
        .delete()
        .eq('id', bookmarkId);
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    if (_userId == null) return false;
    final response = await _client
        .from(AppStrings.tableBookmarks)
        .select('id')
        .eq('user_id', _userId!)
        .eq('surah_number', surahNumber)
        .eq('ayah_number', ayahNumber)
        .maybeSingle();
    return response != null;
  }

  // ── User Progress ──

  Future<Map<String, dynamic>?> getTodayProgress() async {
    if (_userId == null) return null;
    final today = DateTime.now().toIso8601String().split('T').first;
    final response = await _client
        .from(AppStrings.tableUserProgress)
        .select()
        .eq('user_id', _userId!)
        .eq('date', today)
        .maybeSingle();
    return response;
  }

  Future<void> upsertProgress(Map<String, dynamic> data) async {
    if (_userId == null) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    data['user_id'] = _userId;
    data['date'] = today;
    data['updated_at'] = DateTime.now().toIso8601String();
    await _client.from(AppStrings.tableUserProgress).upsert(data);
  }

  Future<List<Map<String, dynamic>>> getWeeklyProgress() async {
    if (_userId == null) return [];
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final response = await _client
        .from(AppStrings.tableUserProgress)
        .select()
        .eq('user_id', _userId!)
        .gte('date', weekAgo.toIso8601String().split('T').first)
        .order('date');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getFullProgressHistory() async {
    if (_userId == null) return [];
    final response = await _client
        .from(AppStrings.tableUserProgress)
        .select()
        .eq('user_id', _userId!)
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    if (_userId == null) {
      return {
        'total_verses_memorized': 0,
        'total_practice_sessions': 0,
        'total_correct': 0,
        'total_recitations': 0,
      };
    }
    final response = await _client
        .from(AppStrings.tableUserProgress)
        .select()
        .eq('user_id', _userId!);
    final rows = List<Map<String, dynamic>>.from(response);

    int totalMemorized = 0;
    int totalPractice = 0;
    int totalCorrect = 0;
    int totalRecitations = 0;

    for (final row in rows) {
      totalMemorized += (row['verses_memorized'] as int?) ?? 0;
      totalPractice += (row['practice_sessions'] as int?) ?? 0;
      totalCorrect += (row['correct_recitations'] as int?) ?? 0;
      totalRecitations += (row['total_recitations'] as int?) ?? 0;
    }

    return {
      'total_verses_memorized': totalMemorized,
      'total_practice_sessions': totalPractice,
      'total_correct': totalCorrect,
      'total_recitations': totalRecitations,
    };
  }

  // ── Activity Log ──

  Future<void> logActivity({
    required String action,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) return;
    await _client.from(AppStrings.tableActivityLog).insert({
      'user_id': _userId,
      'action': action,
      'description': description,
      'metadata': metadata,
    });
  }
}

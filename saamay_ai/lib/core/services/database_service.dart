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

  // ── Bookmarks ──

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    if (_userId == null) return [];
    final response = await _client
        .from(AppStrings.tableBookmarks)
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? ayahText,
  }) async {
    if (_userId == null) return;
    await _client.from(AppStrings.tableBookmarks).upsert({
      'user_id': _userId,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'surah_name': surahName,
      'ayah_text': ayahText,
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

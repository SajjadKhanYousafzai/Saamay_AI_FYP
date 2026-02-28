import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBookmarks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookmarks = await _db.getBookmarks();
    } catch (e) {
      _error = 'Error loading bookmarks: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeBookmark(String id) async {
    try {
      await _db.removeBookmark(id);
      _bookmarks.removeWhere((b) => b['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error removing bookmark: $e';
      notifyListeners();
    }
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? ayahText,
  }) async {
    try {
      await _db.addBookmark(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        ayahText: ayahText,
      );
      await loadBookmarks();
    } catch (e) {
      _error = 'Error adding bookmark: $e';
      notifyListeners();
    }
  }
}

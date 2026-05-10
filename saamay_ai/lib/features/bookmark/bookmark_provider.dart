import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  List<Map<String, dynamic>> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBookmarks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _folders = await _db.getBookmarkFolders();
      _bookmarks = await _db.getBookmarks(); // fetches uncategorized by default if folderId is null
    } catch (e) {
      _error = 'Error loading bookmarks: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFolders() async {
    try {
      _folders = await _db.getBookmarkFolders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading folders: $e');
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final newFolder = await _db.createBookmarkFolder(name);
      if (newFolder != null) {
        _folders.insert(0, newFolder);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error creating folder: $e';
      notifyListeners();
    }
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
    String? folderId,
  }) async {
    try {
      await _db.addBookmark(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        ayahText: ayahText,
        folderId: folderId,
      );
      await loadBookmarks();
    } catch (e) {
      _error = 'Error adding bookmark: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }
}

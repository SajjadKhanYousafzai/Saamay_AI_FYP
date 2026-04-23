import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';

class FolderDetailsScreen extends StatefulWidget {
  final String folderId;
  final String folderName;

  const FolderDetailsScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolderBookmarks();
  }

  Future<void> _loadFolderBookmarks() async {
    setState(() => _isLoading = true);
    try {
      _bookmarks = await _db.getBookmarks(folderId: widget.folderId);
    } catch (e) {
      debugPrint('Error loading folder bookmarks: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteBookmark(String id) async {
    try {
      await _db.removeBookmark(id);
      setState(() => _bookmarks.removeWhere((b) => b['id'] == id));
    } catch (e) {
      debugPrint('Error deleting bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101321) : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.folderName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'This folder is empty',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return Dismissible(
                      key: Key(bookmark['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: AppColors.error),
                      ),
                      onDismissed: (_) => _deleteBookmark(bookmark['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${bookmark['surah_number']}:${bookmark['ayah_number']}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookmark['surah_name'],
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (bookmark['ayah_text'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      bookmark['ayah_text'],
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : AppColors.textGrey,
                                        fontSize: 14,
                                        fontFamily: 'Amiri',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'bookmark_provider.dart';
import 'package:provider/provider.dart';

class FolderSelectionSheet extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String? ayahText;

  const FolderSelectionSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    this.ayahText,
  });

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    String? ayahText,
  }) {
    // Ensure BookmarkProvider is initialized and folders are loaded
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => BookmarkProvider()..loadFolders(),
        child: FolderSelectionSheet(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
          ayahText: ayahText,
        ),
      ),
    );
  }

  @override
  State<FolderSelectionSheet> createState() => _FolderSelectionSheetState();
}

class _FolderSelectionSheetState extends State<FolderSelectionSheet> {
  final TextEditingController _folderNameController = TextEditingController();
  bool _isCreating = false;

  void _saveBookmark(BuildContext context, String? folderId, BookmarkProvider provider) async {
    try {
      await provider.addBookmark(
        surahNumber: widget.surahNumber,
        ayahNumber: widget.ayahNumber,
        surahName: widget.surahName,
        ayahText: widget.ayahText,
        folderId: folderId,
      );
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayah Saved successfully!'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _createFolderAndSave(BookmarkProvider provider) async {
    if (_folderNameController.text.trim().isEmpty) return;
    await provider.createFolder(_folderNameController.text.trim());
    if (provider.folders.isNotEmpty) {
      if (!mounted) return;
      _saveBookmark(context, provider.folders.first['id'], provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<BookmarkProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Save to Bookmark',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          
          if (_isCreating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _folderNameController,
                      autofocus: true,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Folder Name...',
                        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2D3E) : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 32),
                    onPressed: () => _createFolderAndSave(provider),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => setState(() => _isCreating = true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.create_new_folder, color: AppColors.primaryGreen),
                      const SizedBox(width: 16),
                      Text(
                        'Create New Folder',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          const SizedBox(height: 20),
          const Divider(),
          
          Expanded(
            flex: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: Icon(Icons.bookmark_border, color: isDark ? Colors.white70 : Colors.black87),
                    title: Text(
                      'Uncategorized (General)',
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _saveBookmark(context, null, provider),
                  ),
                  ...provider.folders.map((folder) => ListTile(
                    leading: const Icon(Icons.folder, color: AppColors.warning),
                    title: Text(
                      folder['name'],
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _saveBookmark(context, folder['id'], provider),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

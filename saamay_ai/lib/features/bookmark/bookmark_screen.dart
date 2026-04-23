import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'bookmark_provider.dart';
import 'folder_details_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookmarkProvider()
        ..loadFolders()
        ..loadBookmarks(),
      child: const _BookmarkView(),
    );
  }
}

class _BookmarkView extends StatelessWidget {
  const _BookmarkView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarkProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101321) : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadFolders();
                await provider.loadBookmarks();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Folders Section
                  Row(
                    children: [
                      const Icon(Icons.folder_special, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Collections',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (provider.folders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No custom folders created yet. Bookmark an Ayah to create one!',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: provider.folders.length,
                      itemBuilder: (context, index) {
                        final folder = provider.folders[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FolderDetailsScreen(
                                  folderId: folder['id'],
                                  folderName: folder['name'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.folder, size: 40, color: AppColors.warning),
                                const SizedBox(height: 8),
                                Text(
                                  folder['name'],
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Uncategorized Section
                  Row(
                    children: [
                      const Icon(Icons.bookmark, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Uncategorized',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (provider.bookmarks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No uncategorized bookmarks',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = provider.bookmarks[index];
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
                          onDismissed: (_) => provider.removeBookmark(bookmark['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1D2A) : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
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
                ],
              ),
            ),
    );
  }
}

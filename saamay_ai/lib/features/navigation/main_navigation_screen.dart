import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../config/routes/app_routes.dart';
import '../home/home_screen.dart';
import '../memorize/memorize_screen.dart';
import '../recite/recite_screen.dart';
import '../retain/retain_screen.dart';
import '../track/track_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(onFeatureTap: _onFeatureTap),
      const MemorizeScreen(),
      const ReciteScreen(),
      const RetainScreen(),
      const TrackScreen(),
    ]);
  }

  void _onFeatureTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: SizedBox(
        width: 230,
        child: Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 230,
                margin: const EdgeInsets.only(top: 8, left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryGreen,
                            child: Text(
                              _getUserInitial(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getUserName(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _authService.currentUser?.email ?? '',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu items
                    _compactDrawerItem(
                      icon: Icons.home,
                      label: AppStrings.home,
                      isActive: _selectedIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedIndex = 0);
                      },
                    ),
                    _compactDrawerItem(
                      icon: Icons.bookmark_outline,
                      label: AppStrings.bookmark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.bookmark);
                      },
                    ),
                    _compactDrawerItem(
                      icon: Icons.palette_outlined,
                      label: 'Theme',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.themeSelection);
                      },
                    ),
                    _compactDrawerItem(
                      icon: Icons.settings_outlined,
                      label: AppStrings.settings,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),

                    const SizedBox(height: 4),
                    const Divider(),

                    // Logout
                    _compactDrawerItem(
                      icon: Icons.logout,
                      label: AppStrings.logout,
                      color: AppColors.error,
                      onTap: () {
                        Navigator.pop(context);
                        _logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline),
                label: AppStrings.memorize,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: AppStrings.recite,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.hearing),
                label: AppStrings.retain,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: AppStrings.track,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isActive = false,
  }) {
    final itemColor = color ?? (isActive ? AppColors.primaryGreen : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(icon, color: itemColor ?? AppColors.textGrey, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }

  String _getUserName() {
    final user = _authService.currentUser;
    if (user == null) return 'User';
    // Try display name from user metadata
    final meta = user.userMetadata;
    if (meta != null) {
      final name = meta['display_name'] ?? meta['full_name'] ?? meta['name'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    }
    // Fallback: capitalize email username
    final username = user.email?.split('@')[0] ?? 'User';
    return username[0].toUpperCase() + username.substring(1);
  }

  String _getUserInitial() {
    final name = _getUserName();
    return name[0].toUpperCase();
  }
}

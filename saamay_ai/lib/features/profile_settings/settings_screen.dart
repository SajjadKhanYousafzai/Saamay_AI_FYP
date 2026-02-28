import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../config/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final authService = AuthService();
    final user = authService.currentUser;

    // Get user display name
    String userName = 'User';
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        final name = meta['display_name'] ?? meta['full_name'] ?? meta['name'];
        if (name != null && name.toString().isNotEmpty) {
          userName = name.toString();
        } else {
          final uname = user.email?.split('@')[0] ?? 'User';
          userName = uname[0].toUpperCase() + uname.substring(1);
        }
      } else {
        final uname = user.email?.split('@')[0] ?? 'User';
        userName = uname[0].toUpperCase() + uname.substring(1);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.primaryGreen, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── User Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    // Gradient avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.info,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Account Section ──
              _sectionTitle(context, 'Account'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _settingsTile(
                    context,
                    icon: Icons.person_outline,
                    iconColor: AppColors.primaryGreen,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    isDark: isDark,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  _tileDivider(isDark),
                  _settingsTile(
                    context,
                    icon: Icons.lock_outline,
                    iconColor: AppColors.info,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _tileDivider(isDark),
                  _settingsTile(
                    context,
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Preferences Section ──
              _sectionTitle(context, 'Preferences'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _settingsTile(
                    context,
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.warning,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _tileDivider(isDark),
                  _settingsTile(
                    context,
                    icon: Icons.palette_outlined,
                    iconColor: AppColors.primaryGreen,
                    title: 'Theme',
                    subtitle: 'Change app appearance',
                    isDark: isDark,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        themeProvider.currentThemeName,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.themeSelection),
                  ),
                  _tileDivider(isDark),
                  _settingsTile(
                    context,
                    icon: Icons.translate,
                    iconColor: AppColors.info,
                    title: 'Language',
                    subtitle: 'English',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Support Section ──
              _sectionTitle(context, 'Support'),
              const SizedBox(height: 10),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _settingsTile(
                    context,
                    icon: Icons.help_outline,
                    iconColor: AppColors.primaryGreen,
                    title: 'Help & Support',
                    subtitle: 'Get help with using the app',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _tileDivider(isDark),
                  _settingsTile(
                    context,
                    icon: Icons.info_outline,
                    iconColor: AppColors.info,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Sign Out Button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.error.withOpacity(0.06),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _tileDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 68,
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing widget or chevron
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textGrey,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}

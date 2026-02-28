import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
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
                  const Spacer(),
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // balance
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Banner card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3BAF8A), Color(0xFF2D9E7D), Color(0xFF1A7A5E)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.palette, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Your Theme',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a theme that suits your preference',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ThemeOptionCard(
                    name: 'Saamay Dark',
                    description: 'Default dark theme with green accents',
                    iconData: Icons.dark_mode,
                    iconBgColor: const Color(0xFF1A7A5E),
                    iconColor: Colors.white,
                    themeType: AppThemeType.saamayDark,
                    isSelected: themeProvider.currentTheme == AppThemeType.saamayDark,
                    onTap: () => themeProvider.setTheme(AppThemeType.saamayDark),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ThemeOptionCard(
                    name: 'White',
                    description: 'Clean and minimal light theme',
                    iconData: Icons.light_mode,
                    iconBgColor: Colors.grey.shade200,
                    iconColor: Colors.grey.shade700,
                    themeType: AppThemeType.white,
                    isSelected: themeProvider.currentTheme == AppThemeType.white,
                    onTap: () => themeProvider.setTheme(AppThemeType.white),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ThemeOptionCard(
                    name: 'Nature Green',
                    description: 'Fresh and natural green theme',
                    iconData: Icons.eco,
                    iconBgColor: const Color(0xFF22C55E),
                    iconColor: Colors.white,
                    themeType: AppThemeType.natureGreen,
                    isSelected: themeProvider.currentTheme == AppThemeType.natureGreen,
                    onTap: () => themeProvider.setTheme(AppThemeType.natureGreen),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ThemeOptionCard(
                    name: 'Freezed Ice',
                    description: 'Cool and refreshing blue theme',
                    iconData: Icons.ac_unit,
                    iconBgColor: const Color(0xFF38BDF8),
                    iconColor: Colors.white,
                    themeType: AppThemeType.freezedIce,
                    isSelected: themeProvider.currentTheme == AppThemeType.freezedIce,
                    onTap: () => themeProvider.setTheme(AppThemeType.freezedIce),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ThemeOptionCard(
                    name: 'Royal Purple',
                    description: 'Elegant and stylish purple theme',
                    iconData: Icons.auto_awesome,
                    iconBgColor: const Color(0xFFA78BFA),
                    iconColor: Colors.white,
                    themeType: AppThemeType.royalPurple,
                    isSelected: themeProvider.currentTheme == AppThemeType.royalPurple,
                    onTap: () => themeProvider.setTheme(AppThemeType.royalPurple),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData iconData;
  final Color iconBgColor;
  final Color iconColor;
  final AppThemeType themeType;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOptionCard({
    required this.name,
    required this.description,
    required this.iconData,
    required this.iconBgColor,
    required this.iconColor,
    required this.themeType,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Theme icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

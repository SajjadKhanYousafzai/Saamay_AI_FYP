import 'package:flutter/material.dart';
import '../../features/auth/loading/loading_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/signup/signup_screen.dart';
import '../../features/auth/reset_password/reset_password_screen.dart';
import '../../features/auth/reset_password/update_password_screen.dart';
import '../../features/navigation/main_navigation_screen.dart';
import '../../features/bookmark/bookmark_screen.dart';
import '../../features/profile_settings/profile_screen.dart';
import '../../features/profile_settings/settings_screen.dart';
import '../../features/profile_settings/theme_selection_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String loading = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String resetPassword = '/reset-password';
  static const String updatePassword = '/update-password';
  static const String mainNavigation = '/main';
  static const String bookmark = '/bookmark';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String themeSelection = '/theme-selection';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case updatePassword:
        return MaterialPageRoute(builder: (_) => const UpdatePasswordScreen());
      case mainNavigation:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case bookmark:
        return MaterialPageRoute(builder: (_) => const BookmarkScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case themeSelection:
        return MaterialPageRoute(builder: (_) => const ThemeSelectionScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

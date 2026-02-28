import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const SaamayAIApp());
}

class SaamayAIApp extends StatelessWidget {
  const SaamayAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Saamay AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(themeProvider.currentTheme),
            darkTheme: AppTheme.getTheme(themeProvider.currentTheme),
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.loading,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}

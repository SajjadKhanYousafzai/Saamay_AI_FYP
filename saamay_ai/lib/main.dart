import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/backend_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  // Fire-and-forget: pre-warm the Modal backend so first recording is fast
  BackendService.warmup();
  runApp(const SaamayAIApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SaamayAIApp extends StatefulWidget {
  const SaamayAIApp({super.key});

  @override
  State<SaamayAIApp> createState() => _SaamayAIAppState();
}

class _SaamayAIAppState extends State<SaamayAIApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Automatically navigate to the Update Password screen
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.updatePassword,
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Saamay AI',
            navigatorKey: navigatorKey,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api_routes.dart';
import 'providers/auth_provider.dart';
import 'views/login_view.dart';
import 'views/user_dashboard_view.dart';
import 'views/admin_dashboard_view.dart';
import 'views/terms_and_conditions_view.dart';
import 'views/api_test_view.dart';
import 'views/json_parse_test_view.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize API Routes with saved endpoint
  await ApiRoutes.initialize(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TUI iBanking',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginView(),
        '/user': (context) => const UserDashboardView(),
        '/admin': (context) => const AdminDashboardView(),
        '/terms': (context) => const TermsAndConditionsView(),
        '/api-test': (context) => const ApiTestWidget(),
        '/json-test': (context) => const JsonParseTestWidget(),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire auth state to ensure proper rebuilds
    final authState = ref.watch(authProvider);

    // Show loading while initializing (first time only)
    if (authState.isLoading && authState.token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show appropriate screen based on auth state
    if (authState.isAuthenticated) {
      if (authState.isAdmin) {
        return const AdminDashboardView();
      } else {
        return const UserDashboardView();
      }
    }

    return const LoginView();
  }
}

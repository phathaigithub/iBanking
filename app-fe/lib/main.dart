import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'views/login_view.dart';
import 'views/user_dashboard_view.dart';
import 'views/admin_dashboard_view.dart';
import 'utils/app_theme.dart';
import 'services/tuition_management_service.dart';

void main() {
  // Initialize sample data for demo
  TuitionManagementService().initializeSampleData();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Remove this in production - Demo credentials for demo
    print('DEBUG - Demo Accounts:');
    print('Admin: admin/admin');
    print('Students: 52200001/pass1, 52200002/pass2, 52200003/pass3');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => AdminViewModel()),
      ],
      // child: MaterialApp(
      //   title: 'TUI iBanking',
      //   theme: AppTheme.lightTheme,
      //   debugShowCheckedModeBanner: false,
      //   initialRoute: '/',
      //   routes: {
      //     '/': (context) => const LoginView(),
      //     '/login': (context) => const LoginView(),
      //     '/user': (context) => const UserDashboardView(),
      //     '/admin': (context) => const AdminDashboardView(),
      //   },
      // ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, minWidth: 0),
          child: MaterialApp(
            title: 'TUI iBanking',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginView(),
              '/login': (context) => const LoginView(),
              '/user': (context) => const UserDashboardView(),
              '/admin': (context) => const AdminDashboardView(),
            },
          ),
        ),
      ),
    );
  }
}

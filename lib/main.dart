import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/auth/presentation/screens/splash_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/login_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/register_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:project_uts/shared/providers/theme_provider.dart';

import 'package:project_uts/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:project_uts/features/profile/presentation/screens/profile_screen.dart';

import 'package:project_uts/features/ticket/presentation/screens/ticket_list_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/create_ticket_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/admin_ticket_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_tracking_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_history_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/notification/presentation/providers/notification_provider.dart';
import 'package:project_uts/features/notification/presentation/screens/notification_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // ✅ Auth (SIMPEL - TANPA REPOSITORY)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // Ticket
        ChangeNotifierProvider(
          create: (_) => TicketProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title: 'E-Ticketing Helpdesk',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),

          initialRoute: '/',

          routes: {
            '/': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/forgot-password': (_) => const ForgotPasswordScreen(),
            '/dashboard': (_) => const DashboardScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/tickets': (_) => const TicketListScreen(),
            '/create-ticket': (_) => const CreateTicketScreen(),
            '/admin-tickets': (_) => const AdminTicketScreen(),
            '/notification': (_) => const NotificationScreen(),
            '/history': (_) => const HistoryScreen(),
          },

          // ✅ HANDLE ROUTE YANG BUTUH ARGUMENT
          onGenerateRoute: (settings) {
            if (settings.name == '/ticket-detail') {
              final ticket = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => TicketDetailScreen(ticket: ticket as dynamic),
              );
            }

            return null;
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const seedColor = Color(0xFF1565C0);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            isDark ? const Color(0xFF121212) : Colors.white,
      ),
    );
  }
}
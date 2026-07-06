import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/core/constant/api_endpoints.dart';

import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/auth/presentation/screens/splash_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/login_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/register_screen.dart';
import 'package:project_uts/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:project_uts/shared/providers/theme_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

import 'package:project_uts/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:project_uts/features/profile/presentation/screens/profile_screen.dart';
import 'package:project_uts/features/setting/presentation/screens/setting_screen.dart';

import 'package:project_uts/features/ticket/presentation/screens/ticket_list_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/create_ticket_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/admin_ticket_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_tracking_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_history_screen.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/notification/presentation/providers/notification_provider.dart';
import 'package:project_uts/features/notification/presentation/screens/notification_screen.dart';
import 'package:project_uts/features/user_management/presentation/providers/user_management_provider.dart';
import 'package:project_uts/features/user_management/presentation/screens/user_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiEndpoints.supabaseUrl,
    anonKey: ApiEndpoints.supabaseAnonKey,
  );

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

        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(),
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
            '/setting': (_) => const SettingScreen(),
            '/user-management': (_) => const UserManagementScreen(),
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

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final surfaceColor = isDark ? const Color(0xFF14181F) : const Color(0xFFF6F8FC);
    final cardColor = isDark ? const Color(0xFF1C212B) : Colors.white;

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final textTheme = baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.4),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceColor,
      canvasColor: surfaceColor,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF232937) : const Color(0xFFF1F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : const Color(0xFF64748B),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withOpacity(0.14),
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.primary : null,
          );
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF232937) : const Color(0xFFF1F4F9),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEEF1F6),
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF232937) : const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? colorScheme.primary.withOpacity(0.35)
                : null),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconColor: isDark ? Colors.white70 : const Color(0xFF64748B),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/presentation/widgets/ticket_stats_widget.dart';
import 'package:project_uts/shared/providers/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();

    // load tiket sekali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.user;

      if (user != null) {
        context.read<TicketProvider>().loadTickets(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggle();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // karena ini dashboard
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notif',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/tickets');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/notification');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 GREETING
            Text(
              'Halo, ${auth.user?.name ?? 'User'} 👋',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // 📊 STATISTIK
            const TicketStatsWidget(),

            const SizedBox(height: 24),

            // 📌 MENU
            _MenuCard(
              icon: Icons.confirmation_number,
              title: 'Tiket Saya',
              subtitle: 'Lihat & kelola tiket kamu',
              onTap: () => Navigator.pushNamed(context, '/tickets'),
            ),

            const SizedBox(height: 12),

            _MenuCard(
              icon: Icons.add_circle,
              title: 'Buat Tiket',
              subtitle: 'Laporkan masalah baru',
              onTap: () =>
                  Navigator.pushNamed(context, '/create-ticket'),
            ),

            const SizedBox(height: 12),

            _MenuCard(
              icon: Icons.history,
              title: 'Riwayat Tiket',
              subtitle: 'Lihat riwayat penanganan tiket',
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// 🔹 REUSABLE MENU CARD
// =========================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
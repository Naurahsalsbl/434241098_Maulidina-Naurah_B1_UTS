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
  static const _blue900     = Color(0xFF0D2B6B);
  static const _blue700     = Color(0xFF1565C0);
  // dark mode header lebih gelap
  static const _darkHeader1 = Color(0xFF0A1929);
  static const _darkHeader2 = Color(0xFF0D2B6B);

  @override
  void initState() {
    super.initState();
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
    final auth          = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final ticketProv    = context.watch<TicketProvider>();
    final theme         = Theme.of(context);
    final isDark        = themeProvider.isDark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: _buildBottomNav(context, theme),
      body: Column(
        children: [
          // ── Gradient Header ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [_darkHeader1, _darkHeader2]
                    : [_blue900, _blue700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${auth.user?.name ?? 'User'} 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              context.read<ThemeProvider>().toggle(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white70),
                          onPressed: () async {
                            await auth.logout();
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pantau dan kelola laporan dengan cepat',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.confirmation_number_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${ticketProv.totalTickets} Total Tiket',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(Icons.grid_view_rounded, 'Quick Actions', theme),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    padding: EdgeInsets.zero,
                    children: [
                      _QuickActionCard(
                        icon: Icons.confirmation_number_rounded,
                        title: 'Tiket Saya',
                        onTap: () =>
                            Navigator.pushNamed(context, '/tickets'),
                      ),
                      _QuickActionCard(
                        icon: Icons.add_rounded,
                        title: 'Buat Tiket',
                        onTap: () =>
                            Navigator.pushNamed(context, '/create-ticket'),
                      ),
                      _QuickActionCard(
                        icon: Icons.history_rounded,
                        title: 'Riwayat',
                        onTap: () =>
                            Navigator.pushNamed(context, '/history'),
                      ),
                      _QuickActionCard(
                        icon: Icons.notifications_rounded,
                        title: 'Notifikasi',
                        onTap: () =>
                            Navigator.pushNamed(context, '/notification'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel(
                      Icons.bar_chart_rounded, 'Statistik Tiket', theme),
                  const SizedBox(height: 12),
                  const TicketStatsWidget(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _blue700),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme) {
    return NavigationBar(
      selectedIndex: 0,
      indicatorColor: _blue700.withOpacity(0.15),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: _blue700),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: const Icon(Icons.confirmation_number_outlined),
          selectedIcon: Icon(Icons.confirmation_number, color: _blue700),
          label: 'Tiket',
        ),
        NavigationDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications, color: _blue700),
          label: 'Notif',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: _blue700),
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
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  static const _blue700 = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _blue700.withOpacity(isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _blue700, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
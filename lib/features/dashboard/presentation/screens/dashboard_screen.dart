import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/presentation/widgets/ticket_stats_widget.dart';
import 'package:project_uts/features/notification/presentation/providers/notification_provider.dart';
import 'package:project_uts/shared/providers/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Material 3 Color Palette Refinement
  static const _bluePrimaryLight = Color(0xFF0F52BA);
  static const _blueSecondaryLight = Color(0xFF3B82F6);
  static const _darkHeader1 = Color(0xFF0F172A); // Slate 900
  static const _darkHeader2 = Color(0xFF1E293B); // Slate 800

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.user;
      if (user != null) {
        final ticketProvider = context.read<TicketProvider>();
        if (user.role == 'admin') {
          ticketProvider.loadAllTickets();
        } else if (user.role == 'helpdesk') {
          ticketProvider.loadAssignedTickets(user.id);
        } else {
          ticketProvider.loadTickets(user.id);
        }
      }
    });
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<NotificationProvider>().subscribeToNotifications(userId);
      context.read<NotificationProvider>().loadNotifications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final ticketProv = context.watch<TicketProvider>();
    final theme = Theme.of(context);
    final isDark = themeProvider.isDark;

    final primaryColor = isDark ? _darkHeader1 : _bluePrimaryLight;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: _buildBottomNav(context, theme, primaryColor),
      body: Column(
        children: [
          // ── Premium Gradient Header ───────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [_darkHeader1, _darkHeader2]
                    : [_bluePrimaryLight, _blueSecondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : _bluePrimaryLight).withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar (Greeting & Actions)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo,',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${auth.user?.name ?? 'User'} 👋',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dark Mode Toggle Button
                        _buildHeaderIconButton(
                          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          onPressed: () => context.read<ThemeProvider>().toggle(),
                        ),
                        const SizedBox(width: 8),
                        // Logout Button
                        _buildHeaderIconButton(
                          icon: Icons.logout_rounded,
                          onPressed: () async {
                            await auth.logout();
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pantau dan kelola laporan dengan cepat',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Ticket Total Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.confirmation_number_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ticketProv.totalTickets} Total Tiket',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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

          // ── Body Content ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(Icons.grid_view_rounded, 'Quick Actions', theme, primaryColor),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, auth.user?.role, primaryColor),
                  const SizedBox(height: 28),
                  _sectionLabel(Icons.bar_chart_rounded, 'Statistik Tiket', theme, primaryColor),
                  const SizedBox(height: 16),
                  // Wrapper to ensure layout alignment and padding standardizations
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: const TicketStatsWidget(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        splashRadius: 24,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String? role, Color primaryColor) {
    final List<_QuickActionItem> items;

    switch (role) {
      case 'admin':
        items = const [
          _QuickActionItem(Icons.manage_accounts_rounded, 'Manajemen Tiket', '/admin-tickets'),
          _QuickActionItem(Icons.people_alt_rounded, 'Kelola Pengguna', '/user-management'),
          _QuickActionItem(Icons.add_rounded, 'Buat Tiket', '/create-ticket'),
          _QuickActionItem(Icons.history_rounded, 'Riwayat Laporan', '/history'),
          _QuickActionItem(Icons.notifications_rounded, 'Notifikasi', '/notification'),
        ];
        break;
      case 'helpdesk':
        items = const [
          _QuickActionItem(Icons.assignment_rounded, 'Tiket Ditugaskan', '/tickets'),
          _QuickActionItem(Icons.add_rounded, 'Buat Tiket', '/create-ticket'),
          _QuickActionItem(Icons.history_rounded, 'Riwayat Kerja', '/history'),
          _QuickActionItem(Icons.notifications_rounded, 'Notifikasi Pusat', '/notification'),
        ];
        break;
      default:
        items = const [
          _QuickActionItem(Icons.confirmation_number_rounded, 'Tiket Saya', '/tickets'),
          _QuickActionItem(Icons.add_rounded, 'Buat Tiket Baru', '/create-ticket'),
          _QuickActionItem(Icons.history_rounded, 'Riwayat', '/history'),
          _QuickActionItem(Icons.notifications_rounded, 'Notifikasi', '/notification'),
        ];
    }

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final hasSecond = i + 1 < items.length;
      rows.add(Row(
        children: [
          Expanded(child: _quickActionFromItem(context, items[i], primaryColor)),
          const SizedBox(width: 14),
          Expanded(
            child: hasSecond
                ? _quickActionFromItem(context, items[i + 1], primaryColor)
                : const SizedBox.shrink(),
          ),
        ],
      ));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 14));
    }

    return Column(children: rows);
  }

  Widget _quickActionFromItem(BuildContext context, _QuickActionItem item, Color primaryColor) {
    return _QuickActionCard(
      icon: item.icon,
      title: item.title,
      primaryColor: primaryColor,
      onTap: () => Navigator.pushNamed(context, item.route),
    );
  }

  Widget _sectionLabel(IconData icon, String text, ThemeData theme, Color primaryColor) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: isDark ? const Color(0xFF8DB8FF) : primaryColor, ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme, Color primaryColor) {
    final isDark = theme.brightness == Brightness.dark;

    final selectedColor = isDark
        ? const Color(0xFF8DB8FF)
        : primaryColor;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: 0,
        elevation: 0,
        height: 72,
        backgroundColor: theme.colorScheme.surfaceContainer,
        indicatorColor: primaryColor.withOpacity(0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: selectedColor),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded, color: primaryColor),
            label: 'Tiket',
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded, color: primaryColor),
            label: 'Notif',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: primaryColor),
            label: 'Profil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 0) return;

          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/tickets');
              break;
            case 2:
              Navigator.pushNamed(context, '/notification');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        }
      ),
    );
  }
}

// ── Quick Action Item (data) ────────────────────────────────────────────────
class _QuickActionItem {
  final IconData icon;
  final String title;
  final String route;
  const _QuickActionItem(this.icon, this.title, this.route);
}

// ── Quick Action Card ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color primaryColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 110,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(isDark ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isDark ? const Color(0xFF93C5FD) : primaryColor,  size: 20),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
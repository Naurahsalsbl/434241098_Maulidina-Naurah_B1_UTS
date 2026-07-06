import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/shared/providers/theme_provider.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _indigo     = AppColors.primaryLight;
  static const _indigoDark = AppColors.primaryLight;
  static const _blueEnd    = AppColors.secondaryLight;
  static const _indigoLight = Color(0xFFE7EFFB);

  @override
  Widget build(BuildContext context) {
    final auth          = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final ticketProv    = context.watch<TicketProvider>();
    final user          = auth.user;
    final theme         = Theme.of(context);
    final isDark        = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(isDark),
      bottomNavigationBar: _buildBottomNav(context),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: _indigo,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/setting'),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_indigoDark, _blueEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Statistik Tiket ──────────────────────────
                        _sectionLabel('Statistik Tiket', theme),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _statCard(
                              label: 'Total',
                              count: ticketProv.totalTickets,
                              color: _indigo,
                              icon: Icons.confirmation_number_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: 'Open',
                              count: ticketProv.openCount,
                              color: const Color(0xFFEF4444),
                              icon: Icons.radio_button_unchecked_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: 'Selesai',
                              count: ticketProv.closedCount,
                              color: const Color(0xFF10B981),
                              icon: Icons.check_circle_rounded,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Info Akun ────────────────────────────────
                        _sectionLabel('Info Akun', theme),
                        const SizedBox(height: 8),
                        _infoCard(isDark: isDark, children: [
                          _infoTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Nama',
                            value: user.name,
                            theme: theme,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user.email,
                            theme: theme,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.badge_outlined,
                            label: 'Role',
                            value: user.role[0].toUpperCase() +
                                user.role.substring(1),
                            theme: theme,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // ── Menu ─────────────────────────────────────
                        _sectionLabel('Menu', theme),
                        const SizedBox(height: 8),
                        _infoCard(isDark: isDark, children: [
                          _menuTile(
                            icon: Icons.settings_outlined,
                            label: 'Pengaturan',
                            iconColor: _indigo,
                            onTap: () =>
                                Navigator.pushNamed(context, '/setting'),
                            theme: theme,
                          ),
                          _divider(),
                          _menuTile(
                            icon: Icons.lock_outline_rounded,
                            label: 'Ganti Password',
                            iconColor: Colors.orange,
                            onTap: () => Navigator.pushNamed(
                                context, '/forgot-password'),
                            theme: theme,
                          ),
                          _divider(),
                          _menuTile(
                            icon: Icons.history_rounded,
                            label: 'Riwayat Tiket',
                            iconColor: Colors.teal,
                            onTap: () =>
                                Navigator.pushNamed(context, '/history'),
                            theme: theme,
                          ),
                          _divider(),
                          _menuTile(
                            icon: isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            label: isDark ? 'Mode Terang' : 'Mode Gelap',
                            iconColor: Colors.amber,
                            onTap: () =>
                                context.read<ThemeProvider>().toggle(),
                            theme: theme,
                            trailing: Switch(
                              value: isDark,
                              activeColor: _indigo,
                              onChanged: (_) =>
                                  context.read<ThemeProvider>().toggle(),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // ── Logout ───────────────────────────────────
                        _infoCard(isDark: isDark, children: [
                          _menuTile(
                            icon: Icons.logout_rounded,
                            label: 'Keluar',
                            iconColor: Colors.red,
                            labelColor: Colors.red,
                            showArrow: false,
                            onTap: () => _showLogoutDialog(context, auth),
                            theme: theme,
                          ),
                        ]),

                        const SizedBox(height: 32),

                        Center(
                          child: Text(
                            'E-Ticketing Helpdesk v2.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
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

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? labelColor,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
            trailing ??
                (showArrow
                    ? Icon(Icons.chevron_right_rounded,
                        color: Colors.grey.shade400, size: 20)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
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
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onDestinationSelected: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/tickets');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/notification');
        }
      },
    );
  }
}
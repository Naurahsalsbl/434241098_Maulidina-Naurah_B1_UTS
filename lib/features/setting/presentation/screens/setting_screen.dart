import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/shared/providers/theme_provider.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static const _indigo = AppColors.primaryLight;
  static const _indigoLight = Color(0xFFE7EFFB);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(isDark),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: _indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Card ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _indigoLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _indigo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '-',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '-',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _indigoLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role.toUpperCase() ?? '-',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _indigo,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tampilan ─────────────────────────────────────────────
            _sectionLabel('Tampilan', theme),
            const SizedBox(height: 8),
            _settingCard(
              isDark: isDark,
              child: Column(
                children: [
                  _themeOption(
                    context: context,
                    label: 'Terang',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) => themeProvider.setTheme(val!),
                  ),
                  _divider(),
                  _themeOption(
                    context: context,
                    label: 'Gelap',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) => themeProvider.setTheme(val!),
                  ),
                  _divider(),
                  _themeOption(
                    context: context,
                    label: 'Ikuti Sistem',
                    icon: Icons.settings_suggest_outlined,
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) => themeProvider.setTheme(val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Akun ─────────────────────────────────────────────────
            _sectionLabel('Akun', theme),
            const SizedBox(height: 8),
            _settingCard(
              isDark: isDark,
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Ganti Password',
                    iconColor: _indigo,
                    onTap: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                    theme: theme,
                  ),
                  _divider(),
                  _settingTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Tentang Aplikasi',
                    iconColor: Colors.teal,
                    onTap: () => _showAboutDialog(context),
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Logout ───────────────────────────────────────────────
            _settingCard(
              isDark: isDark,
              child: _settingTile(
                icon: Icons.logout_rounded,
                label: 'Keluar',
                iconColor: Colors.red,
                labelColor: Colors.red,
                showArrow: false,
                onTap: () => _showLogoutDialog(context, auth),
                theme: theme,
              ),
            ),

            const SizedBox(height: 32),

            // ── Version ──────────────────────────────────────────────
            Center(
              child: Text(
                'E-Ticketing Helpdesk v2.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

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

  Widget _settingCard({required bool isDark, required Widget child}) {
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
      child: child,
    );
  }

  Widget _themeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? _indigo : Colors.grey.shade400),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? _indigo
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: _indigo, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? labelColor,
    bool showArrow = true,
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
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-Ticketing Helpdesk'),
            SizedBox(height: 4),
            Text('Versi 2.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 8),
            Text(
              'Aplikasi pelaporan dan pengelolaan tiket helpdesk untuk DIV Teknik Informatika Universitas Airlangga.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _indigo),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
}
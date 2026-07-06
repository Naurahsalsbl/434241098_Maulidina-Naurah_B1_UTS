import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';
import 'package:project_uts/features/user_management/presentation/providers/user_management_provider.dart';
import 'package:project_uts/core/constant/app_colors.dart';

const _indigo = AppColors.primaryLight;
const _indigoLight = Color(0xFFE7EFFB);

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _roleFilters = const ['Semua', 'User', 'Helpdesk', 'Admin'];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => AppColors.surface(_isDark);
  Color get _cardBg => AppColors.card(_isDark);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roleFilters.length, vsync: this);
    Future.microtask(() => context.read<UserManagementProvider>().loadUsers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return all.where((u) => u.role == 'user').toList();
      case 2:
        return all.where((u) => u.role == 'helpdesk').toList();
      case 3:
        return all.where((u) => u.role == 'admin').toList();
      default:
        return all;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'helpdesk':
        return const Color(0xFFF59E0B);
      default:
        return _indigo;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'helpdesk':
        return 'Helpdesk';
      default:
        return 'User';
    }
  }

  Future<void> _confirmToggle(BuildContext context, UserModel user) async {
    final activating = !user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(activating ? 'Aktifkan Akun' : 'Nonaktifkan Akun'),
        content: Text(
          activating
              ? '${user.name} akan bisa login kembali.'
              : '${user.name} tidak akan bisa login sampai diaktifkan kembali.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: activating ? _indigo : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(activating ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context
          .read<UserManagementProvider>()
          .toggleActive(user.id, activating);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      //backgroundColor: _bg,
        body: Column(
    children: [

      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1B2940)
              : const Color(0xFF2F6FE4),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [

              const SizedBox(height: 8),

              Row(
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      "Kelola Pengguna",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 16),

              TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: _roleFilters.map((e) => Tab(text: e)).toList(),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      Expanded(
        child: RefreshIndicator(
        onRefresh: () => provider.loadUsers(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: _indigo))
            : AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) {
                  final filtered = _filter(provider.users, _tabController.index);

                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text('Tidak ada pengguna',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final user = filtered[i];
                      final roleColor = _roleColor(user.role);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: _indigoLight,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: _indigo,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: roleColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _roleLabel(user.role),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: roleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: user.isActive
                                          ? const Color(0xFF10B981)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: user.isActive,
                              activeColor: _indigo,
                              onChanged: (_) => _confirmToggle(context, user),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
        
      ),
    ),
  ], 
),
);
  }
    }
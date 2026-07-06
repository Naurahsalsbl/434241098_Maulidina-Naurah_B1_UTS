import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/notification/presentation/providers/notification_provider.dart';
import 'package:project_uts/features/notification/domain/notification_model.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _indigo = AppColors.primaryLight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<NotificationProvider>().loadNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(isDark),

      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
              ? const Color(0xFF1B2940)
              : const Color(0xFF2F6FE4),
              borderRadius: BorderRadius.only(
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
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),

                      const Expanded(
                        child: Text(
                          "Notifikasi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      if (notifProvider.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${notifProvider.unreadCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                    ],
                  ),

                  const SizedBox(height: 12),

                  if (notifProvider.unreadCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2F6FE4),
                          ),
                          onPressed: () {
                            final userId = auth.user?.id;
                            if (userId != null) {
                              notifProvider.markAllAsRead(userId);
                            }
                          },
                          icon: const Icon(Icons.done_all),
                          label: const Text("Tandai semua dibaca"),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: notifProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _indigo),
                  )
                : notifProvider.notifications.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        color: _indigo,
                        onRefresh: () async {
                          final userId = auth.user?.id;
                          if (userId != null) {
                            await notifProvider.loadNotifications(userId);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          itemCount: notifProvider.notifications.length,
                          itemBuilder: (_, i) {
                            final notif = notifProvider.notifications[i];
                            return _NotificationItem(
                              notification: notif,
                              onTap: () {
                                notifProvider.markAsRead(notif.id);
                                if (notif.ticketId != null) {
                                  Navigator.pushNamed(
                                    context,
                                    '/ticket-detail',
                                    arguments: notif.ticketId,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),

                  ],
                ),
                bottomNavigationBar: _buildBottomNav(context),
              );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A44) : const Color(0xFFE7EFFB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_outlined,
                size: 48, color: _indigo),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
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
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  static const _indigo = AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? (isDark
                ? _indigo.withOpacity(0.08)
                : _indigo.withOpacity(0.04))
            : null,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnread
                    ? _indigo.withOpacity(0.12)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnread
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                color: isUnread ? _indigo : Colors.grey.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _indigo,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM, HH:mm')
                        .format(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
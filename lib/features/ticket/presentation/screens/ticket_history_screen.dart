import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_tracking_screen.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  // Admin/Helpdesk melihat seluruh tiket, User hanya tiketnya sendiri
  void _loadTickets() {
    final auth = context.read<AuthProvider>();
    final ticketProvider = context.read<TicketProvider>();
    final user = auth.user;
    if (user == null) return;

    if (user.role == 'admin' || user.role == 'helpdesk') {
      ticketProvider.loadAllTickets();
    } else {
      ticketProvider.loadTickets(user.id);
    }
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return AppColors.statusOpen;
      case TicketStatus.assigned:
        return AppColors.statusAssigned;
      case TicketStatus.inProgress:
        return AppColors.statusInProgress;
      case TicketStatus.closed:
        return AppColors.statusClosed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sorted = [...ticketProvider.tickets]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
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
                          "Riwayat Tiket",
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Expanded(
            child: ticketProvider.isLoadingTickets
                ? const Center(
                    child: CircularProgressIndicator(),
                  )

                // EMPTY STATE
                : sorted.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada riwayat tiket',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )

                    // LIST DATA
                    : RefreshIndicator(
                        onRefresh: () async => _loadTickets(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: sorted.length,
                          itemBuilder: (_, i) {
                            final ticket = sorted[i];
                            final color = _statusColor(ticket.status);

                            return _HistoryItem(
                              ticket: ticket,
                              color: color,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TicketTrackingScreen(ticket: ticket),
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

class _HistoryItem extends StatelessWidget {
  final TicketModel ticket;
  final Color color;
  final VoidCallback onTap;

  const _HistoryItem({
    required this.ticket,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TIMELINE
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 60,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.status.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'TKT-${ticket.id.substring(0,6).toUpperCase()}',
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Diupdate: ${DateFormat('dd MMM yyyy, HH:mm').format(ticket.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentCtrl = TextEditingController();
  

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:       return Colors.red;
      case TicketStatus.inProgress: return Colors.orange;
      case TicketStatus.resolved:   return Colors.green;
      case TicketStatus.closed:     return Colors.grey;
    }
  }

  void _sendComment() {
    if (_commentCtrl.text.trim().isEmpty) return;

    context.read<TicketProvider>().addComment(
    _commentCtrl.text.trim(),
    );

    _commentCtrl.clear();
  }

  void _showStatusDialog(BuildContext context, String ticketId) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TicketStatus.values.map((status) {
            return ListTile(
              title: Text(status.label),
              onTap: () {
                context
                    .read<TicketProvider>()
                    .updateTicketStatus(ticketId, status);

                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    final comments = ticketProvider.comments;

    final ticket = widget.ticket;
    final color = _statusColor(ticket.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.id),
      ),
      body: Column(
        children: [
          // =========================
          // DETAIL
          // =========================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    ticket.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // DATE
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm')
                        .format(ticket.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  // DESC
                  Text(ticket.description),

                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                // =========================
                // 🔹 ACTION BUTTONS (FR-006)
                // =========================
                if (auth.user?.isAdmin == true || auth.user?.isHelpdesk == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aksi',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // ASSIGN
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<TicketProvider>().assignTicket(
                                      ticket.id,
                                      auth.user?.name ?? 'Helpdesk',
                                    );
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Assign'),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // UPDATE STATUS
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showStatusDialog(context, ticket.id);
                              },
                              icon: const Icon(Icons.update),
                              label: const Text('Update Status'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // =========================
                  // COMMENT SECTION
                  // =========================
                  Text(
                    'Komentar',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (comments.isEmpty)
                    const Text("Belum ada komentar")
                  else
                    ...comments.map(
                      (c) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(auth.user?.name ?? 'User'),
                        subtitle: Text(c),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // =========================
                  // ACTION (TEST)
                  // =========================
                  ElevatedButton(
                    onPressed: () {
                      ticketProvider.updateTicketStatus(
                        ticket.id,
                        TicketStatus.resolved,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Mark as Resolved"),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // INPUT COMMENT
          // =========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: "Tulis komentar...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendComment,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
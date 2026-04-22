import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/presentation/widgets/comment_bubble.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class AdminTicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;
  const AdminTicketDetailScreen({super.key, required this.ticket});

  @override
  State<AdminTicketDetailScreen> createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  TicketStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TicketProvider>()
          .loadTicketDetail(widget.ticket.id);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return Colors.red;
      case TicketStatus.inProgress: return Colors.orange;
      case TicketStatus.resolved:   return Colors.green;
      case TicketStatus.closed:     return Colors.grey;
    }
  }

  Future<void> _updateStatus(TicketStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
            'Ubah status tiket menjadi "${newStatus.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Update')),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await context
        .read<TicketProvider>()
        .updateTicketStatus(widget.ticket.id, newStatus);

    if (!mounted) return;
    if (success) {
      setState(() => _selectedStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Status berhasil diupdate'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _assignToMe() async {
    final auth = context.read<AuthProvider>();
    final success = await context
        .read<TicketProvider>()
        .assignTicket(widget.ticket.id, auth.user!.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Tiket di-assign ke kamu' : 'Gagal assign tiket'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final message = _commentCtrl.text.trim();
    _commentCtrl.clear();

    await context.read<TicketProvider>().addComment(
          ticketId: widget.ticket.id,
          userId: auth.user!.id,
          userName: auth.user!.name,
          message: message,
        );

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.id),
        actions: [
          // Assign ke diri sendiri
          if (auth.user?.isHelpdesk == true)
            TextButton.icon(
              onPressed: _assignToMe,
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Assign'),
            ),
        ],
      ),
      body: ticketProvider.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Update status — khusus admin/helpdesk
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Update Status',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: TicketStatus.values.map((s) {
                                  final isSelected = _selectedStatus == s;
                                  final color = _statusColor(s);
                                  return ChoiceChip(
                                    label: Text(s.label),
                                    selected: isSelected,
                                    onSelected: (_) => _updateStatus(s),
                                    selectedColor: color.withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: isSelected ? color : null,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Judul & info tiket
                        Text(ticket.title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              'User ID: ${ticket.userId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(ticket.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(ticket.description,
                              style: theme.textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 24),

                        // Komentar
                        Text('Balasan',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (ticketProvider.comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Belum ada balasan',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5)),
                              ),
                            ),
                          )
                        else
                          ...ticketProvider.comments.map((c) => CommentBubble(
                                comment: c,
                                isMe: c.userId == auth.user?.id,
                              )),
                      ],
                    ),
                  ),
                ),

                // Input balasan
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Tulis balasan...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          maxLines: null,
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ticketProvider.isSendingComment
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : IconButton.filled(
                              onPressed: _sendComment,
                              icon: const Icon(Icons.send),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
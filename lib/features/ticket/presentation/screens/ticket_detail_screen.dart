import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentCtrl = TextEditingController();

  String? _helpdeskName(String? assignedTo) {
    if (assignedTo == null) return null;

    final provider = context.read<TicketProvider>();

    final match = provider.helpdeskUsers.where((u) => u.id == assignedTo);

    return match.isNotEmpty ? match.first.name : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().loadComments(widget.ticket.id);
      context.read<TicketProvider>().loadHelpdeskUsers();
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:       return AppColors.statusOpen;
      case TicketStatus.assigned:   return AppColors.statusAssigned;
      case TicketStatus.inProgress: return AppColors.statusInProgress;
      case TicketStatus.closed:     return AppColors.statusClosed;
    }
  }

  void _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final ticketProvider = context.read<TicketProvider>();
    await ticketProvider.addComment(
      ticketId: widget.ticket.id,
      userId: auth.user?.id ?? '',
      userName: auth.user?.name ?? 'User',
      message: _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();
  }



  // ── Admin menerima tiket (Open → Assigned) ──────────────────────────────────
  Future<void> _acceptTicket(BuildContext context, TicketModel ticket) async {
    final auth = context.read<AuthProvider>();
    await context.read<TicketProvider>().acceptTicket(
          ticket.id,
          userId: auth.user?.id,
          userName: auth.user?.name,
        );
  }

  // ── Helpdesk menyelesaikan tiket (In Progress → Closed) ─────────────────────
  Future<void> _finishTicket(BuildContext context, TicketModel ticket) async {
    final auth = context.read<AuthProvider>();
    await context.read<TicketProvider>().finishTicket(
          ticket.id,
          userId: auth.user?.id,
          userName: auth.user?.name,
        );
  }

  // ── Admin memilih akun Helpdesk dari database (Assigned → In Progress) ──────
  void _showAssignSheet(BuildContext context, TicketModel ticket) {
    final ticketProvider = context.read<TicketProvider>();
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Petugas Helpdesk',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (ticketProvider.isLoadingHelpdeskUsers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (ticketProvider.helpdeskUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Belum ada akun Helpdesk terdaftar'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ticketProvider.helpdeskUsers.length,
                    itemBuilder: (_, i) {
                      final hd = ticketProvider.helpdeskUsers[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            hd.name.isNotEmpty ? hd.name[0].toUpperCase() : '?',
                          ),
                        ),
                        title: Text(hd.name),
                        subtitle: Text(hd.email),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await ticketProvider.assignTicket(
                            ticket.id,
                            hd.id,
                            userId: auth.user?.id,
                            userName: auth.user?.name,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(
      BuildContext context, AuthProvider auth, TicketModel ticket) {
    final theme = Theme.of(context);
    final role = auth.user?.role;

    Widget? actionButton;

    if (role == 'admin') {
      if (ticket.status == TicketStatus.open) {
        actionButton = ElevatedButton.icon(
          onPressed: () => _acceptTicket(context, ticket),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Terima Tiket'),
        );
      } else if (ticket.status == TicketStatus.assigned) {
        actionButton = ElevatedButton.icon(
          onPressed: () => _showAssignSheet(context, ticket),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Assign Helpdesk'),
        );
      }
    } else if (role == 'helpdesk') {
      if (ticket.status == TicketStatus.inProgress) {
        actionButton = ElevatedButton.icon(
          onPressed: () => _finishTicket(context, ticket),
          icon: const Icon(Icons.task_alt),
          label: const Text('Selesaikan (Finish)'),
        );
      }
    }

    // User biasa, atau admin/helpdesk di luar status yang relevan → tidak ada aksi
    if (actionButton == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: actionButton),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<CommentModel> comments = ticketProvider.comments;
    final ticket = widget.ticket;
    final color = _statusColor(ticket.status);

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
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,
            bottom: 12,
          ),
          child: Row(
            children: [

              IconButton(
                onPressed: ()=>Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Text(
                  ticket.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/ticket-tracking',
                  arguments: ticket,
                ),
                icon: const Icon(
                  Icons.timeline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    ticket.status.label,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  "TKT-${ticket.id.substring(0, 6).toUpperCase()}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              ticket.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat("dd MMM yyyy • HH:mm")
                                      .format(ticket.createdAt),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              ticket.description,
                              style: theme.textTheme.bodyMedium,
                            ),

                            if (ticket.assignedTo != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Ditangani: ${_helpdeskName(ticket.assignedTo) ?? 'Belum ditugaskan'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
      

                  // =========================
                  // ACTION BUTTON — sesuai role & status tiket saat ini
                  // =========================
                  _buildActionSection(context, auth, ticket),

                  // =========================
                  // COMMENT SECTION
                  // =========================
                  Text(
                    'Komentar',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (ticketProvider.isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (comments.isEmpty)
                    const Text('Belum ada komentar')
                  else
                    ...comments.map(
                      (c) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.userName),
                        subtitle: Text(c.message),
                        trailing: Text(
                          DateFormat('HH:mm').format(c.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
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
                            hintText: 'Tulis komentar...',
                          ),
                        ),
                      ),
                      ticketProvider.isLoadingComments
                          ? const SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _sendComment,
                              icon: const Icon(Icons.send),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
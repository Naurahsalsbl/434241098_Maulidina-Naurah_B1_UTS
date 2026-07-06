import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class AdminTicketScreen extends StatefulWidget {
  const AdminTicketScreen({super.key});

  @override
  State<AdminTicketScreen> createState() => _AdminTicketScreenState();
}

class _AdminTicketScreenState extends State<AdminTicketScreen> {
  // Aksen biru — sengaja tetap sama di light & dark supaya kontras selalu terjaga
  static const _indigo = AppColors.primaryLight;      // 0xFF0F52BA — accent utama
  static const _blueEnd = AppColors.secondaryLight;   // 0xFF3B82F6 — gradient sisi terang

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => AppColors.surface(_isDark);
  Color get _cardBg => AppColors.card(_isDark);
  Color get _indigoLight =>
      _isDark ? const Color(0xFF1E2A44) : const Color(0xFFE7EFFB);

  TicketStatus? _filterStatus;
  String? _filterHelpdeskId; // null = semua, _unassigned = belum ditugaskan
  static const _unassigned = '__unassigned__';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TicketProvider>().loadAllTickets();
      context.read<TicketProvider>().loadHelpdeskUsers();
    });
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return AppColors.statusOpen;
      case TicketStatus.assigned:   return AppColors.statusAssigned;
      case TicketStatus.inProgress: return AppColors.statusInProgress;
      case TicketStatus.closed:     return AppColors.statusClosed;
    }
  }

  Color _statusBg(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return const Color(0xFFFEF2F2);
      case TicketStatus.assigned:   return const Color(0xFFEEF2FF);
      case TicketStatus.inProgress: return const Color(0xFFFFFBEB);
      case TicketStatus.closed:     return const Color(0xFFF9FAFB);
    }
  }

  IconData _statusIcon(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return Icons.radio_button_unchecked_rounded;
      case TicketStatus.assigned:   return Icons.assignment_turned_in_rounded;
      case TicketStatus.inProgress: return Icons.timelapse_rounded;
      case TicketStatus.closed:     return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final allTickets = ticketProvider.tickets;
    final tickets = allTickets.where((t) {
      // Default (tanpa filter status) = tiket yang belum closed,
      // sesuai SRS: Admin tracking tiket yang belum ter-close.
      // Tiket closed tetap bisa dilihat lewat chip "Closed" secara eksplisit.
      final statusMatch = _filterStatus == null
          ? t.status != TicketStatus.closed
          : t.status == _filterStatus;
      final helpdeskMatch = _filterHelpdeskId == null
          ? true
          : _filterHelpdeskId == _unassigned
              ? t.assignedTo == null
              : t.assignedTo == _filterHelpdeskId;
      return statusMatch && helpdeskMatch;
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _indigo,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_indigo, _blueEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.confirmation_number_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manajemen Tiket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Panel Admin',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Row(
                          children: [
                            _statBox('Total', allTickets.length, Icons.list_alt_rounded),
                            const SizedBox(width: 10),
                            _statBox('Baru', ticketProvider.openCount, Icons.fiber_new_rounded),
                            const SizedBox(width: 10),
                            _statBox('Proses', ticketProvider.inProgressCount, Icons.timelapse_rounded),
                            const SizedBox(width: 10),
                            _statBox('Selesai', ticketProvider.closedCount, Icons.check_circle_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips: status ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(null, 'Aktif', Icons.apps_rounded),
                    const SizedBox(width: 8),
                    ...TicketStatus.values.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _filterChip(s, s.label, _statusIcon(s)),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter chips: helpdesk ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _helpdeskFilterChip(null, 'Semua Petugas', Icons.groups_rounded),
                    const SizedBox(width: 8),
                    _helpdeskFilterChip(_unassigned, 'Belum Ditugaskan', Icons.person_off_rounded),
                    const SizedBox(width: 8),
                    ...ticketProvider.helpdeskUsers.map((hd) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _helpdeskFilterChip(hd.id, hd.name, Icons.support_agent_rounded),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // ── Count label ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                '${tickets.length} tiket${_activeFilterLabel(ticketProvider)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Ticket list ───────────────────────────────────────────
          ticketProvider.isLoadingTickets
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _indigo),
                  ),
                )
              : tickets.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildTicketCard(
                              context, tickets[index], ticketProvider),
                          childCount: tickets.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  // ── Label filter aktif (status + helpdesk) ──────────────────────────────────
  String _activeFilterLabel(TicketProvider ticketProvider) {
    final parts = <String>[];
    if (_filterStatus != null) parts.add(_filterStatus!.label);
    if (_filterHelpdeskId == _unassigned) {
      parts.add('Belum Ditugaskan');
    } else if (_filterHelpdeskId != null) {
      final match = ticketProvider.helpdeskUsers
          .where((u) => u.id == _filterHelpdeskId);
      if (match.isNotEmpty) parts.add(match.first.name);
    }
    return parts.isEmpty ? '' : ' · ${parts.join(' · ')}';
  }

  // ── Stat box ──────────────────────────────────────────────────────────────
  Widget _statBox(String label, int count, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text('$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ── Helpdesk filter chip ──────────────────────────────────────────────────
  Widget _helpdeskFilterChip(String? helpdeskId, String label, IconData icon) {
    final isSelected = _filterHelpdeskId == helpdeskId;
    const color = _indigo;
    return GestureDetector(
      onTap: () => setState(() => _filterHelpdeskId = helpdeskId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : _cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chip ───────────────────────────────────────────────────────────
  Widget _filterChip(TicketStatus? status, String label, IconData icon) {
    final isSelected = _filterStatus == status;
    final color = status != null ? _statusColor(status) : _indigo;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : _cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ticket card ───────────────────────────────────────────────────────────
  Widget _buildTicketCard(
      BuildContext context, TicketModel ticket, TicketProvider ticketProvider) {
    final statusColor = _statusColor(ticket.status);
    final statusBg = _statusBg(ticket.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            '/ticket-detail',
            arguments: ticket,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(ticket.status),
                              size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            ticket.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Tombol hapus tiket (Admin)
                    GestureDetector(
                      onTap: () => _confirmDelete(context, ticket),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  ticket.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description preview
                Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _helpdeskName(ticketProvider, ticket.assignedTo),
                        style: TextStyle(
                          fontSize: 12,
                          color: ticket.assignedTo != null
                              ? _indigo
                              : Colors.grey.shade400,
                          fontWeight: ticket.assignedTo != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Aksi sesuai status — mengikuti workflow, tanpa pilihan bebas
                    _buildActionButton(context, ticket),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Resolve nama helpdesk dari id assigned_to ───────────────────────────────
  String _helpdeskName(TicketProvider provider, String? assignedTo) {
    if (assignedTo == null) return 'Belum di-assign';
    final match = provider.helpdeskUsers.where((u) => u.id == assignedTo);
    return match.isNotEmpty ? match.first.name : 'Belum di-assign';
  }

  // ── Tombol aksi sesuai status tiket ─────────────────────────────────────────
  Widget _buildActionButton(BuildContext context, TicketModel ticket) {
    switch (ticket.status) {
      case TicketStatus.open:
        return _actionChip(
          label: 'Terima',
          onTap: () => _acceptTicket(context, ticket),
        );
      case TicketStatus.assigned:
        return _actionChip(
          label: 'Assign',
          onTap: () => _showAssignSheet(context, ticket),
        );
      case TicketStatus.inProgress:
      case TicketStatus.closed:
        // Tidak ada aksi admin di status ini — sesuai workflow,
        // perubahan status selanjutnya dilakukan oleh Helpdesk (Finish).
        return const SizedBox.shrink();
    }
  }

  Widget _actionChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _indigoLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _indigo,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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

  // ── Hapus tiket (Admin) — dengan konfirmasi ─────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, TicketModel ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tiket'),
        content: Text(
          'Tiket "${ticket.title}" akan dihapus permanen beserta komentar dan riwayatnya. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success =
        await context.read<TicketProvider>().deleteTicket(ticket.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Tiket berhasil dihapus' : 'Gagal menghapus tiket'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _indigoLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 48, color: _indigo),
          ),
          const SizedBox(height: 16),
          Text(
            (_filterStatus == null && _filterHelpdeskId == null)
                ? 'Belum ada tiket'
                : 'Tidak ada tiket dengan filter ini',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isDark ? Colors.white70 : const Color(0xFF374151)),
          ),
          const SizedBox(height: 4),
          Text(
            'Tiket yang masuk akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Assign bottom sheet — pilih akun Helpdesk dari database ────────────────
  void _showAssignSheet(BuildContext context, TicketModel ticket) {
    final ticketProvider = context.read<TicketProvider>();
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card(Theme.of(sheetContext).brightness == Brightness.dark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Pilih Petugas Helpdesk',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(ticket.title,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),

              if (ticketProvider.isLoadingHelpdeskUsers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(color: _indigo)),
                )
              else if (ticketProvider.helpdeskUsers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada akun Helpdesk terdaftar',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ticketProvider.helpdeskUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final hd = ticketProvider.helpdeskUsers[i];
                      return Material(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await ticketProvider.assignTicket(
                              ticket.id,
                              hd.id,
                              userId: auth.user?.id,
                              userName: auth.user?.name,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _indigoLight,
                                  child: Text(
                                    hd.name.isNotEmpty
                                        ? hd.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: _indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(hd.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      Text(hd.email,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: _indigo),
                              ],
                            ),
                          ),
                        ),
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
}
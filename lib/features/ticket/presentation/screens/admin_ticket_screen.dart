import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class AdminTicketScreen extends StatefulWidget {
  const AdminTicketScreen({super.key});

  @override
  State<AdminTicketScreen> createState() => _AdminTicketScreenState();
}

class _AdminTicketScreenState extends State<AdminTicketScreen> {
  static const _indigo = Color(0xFF4F46E5);
  static const _indigoDark = Color(0xFF3730A3);
  static const _indigoLight = Color(0xFFEEF2FF);
  static const _bg = Color(0xFFF8F9FF);

  TicketStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TicketProvider>().loadAllTickets();
    });
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return const Color(0xFFEF4444);
      case TicketStatus.inProgress: return const Color(0xFFF59E0B);
      case TicketStatus.resolved:   return const Color(0xFF10B981);
      case TicketStatus.closed:     return const Color(0xFF9CA3AF);
    }
  }

  Color _statusBg(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return const Color(0xFFFEF2F2);
      case TicketStatus.inProgress: return const Color(0xFFFFFBEB);
      case TicketStatus.resolved:   return const Color(0xFFECFDF5);
      case TicketStatus.closed:     return const Color(0xFFF9FAFB);
    }
  }

  IconData _statusIcon(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return Icons.radio_button_unchecked_rounded;
      case TicketStatus.inProgress: return Icons.timelapse_rounded;
      case TicketStatus.resolved:   return Icons.check_circle_rounded;
      case TicketStatus.closed:     return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final allTickets = ticketProvider.tickets;
    final tickets = _filterStatus == null
        ? allTickets
        : allTickets.where((t) => t.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _indigo,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_indigoDark, _indigo],
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.confirmation_number_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Manajemen Tiket',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('Panel Admin',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 12)),
                              ],
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
                            _statBox('Selesai', ticketProvider.resolvedCount, Icons.check_circle_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(null, 'Semua', Icons.apps_rounded),
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

          // ── Count label ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                '${tickets.length} tiket${_filterStatus != null ? ' · ${_filterStatus!.label}' : ''}',
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
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
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
        color: Colors.white,
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
                    // Popup menu
                    PopupMenuButton<TicketStatus>(
                      icon: Icon(Icons.more_horiz_rounded,
                          color: Colors.grey.shade400, size: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      onSelected: (status) =>
                          ticketProvider.updateTicketStatus(ticket.id, status),
                      itemBuilder: (_) => TicketStatus.values.map((s) {
                        final c = _statusColor(s);
                        return PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                    color: c, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Text(s.label,
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF111827),
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
                    Text(
                      ticket.assignedTo ?? 'Belum di-assign',
                      style: TextStyle(
                        fontSize: 12,
                        color: ticket.assignedTo != null
                            ? _indigo
                            : Colors.grey.shade400,
                        fontWeight: ticket.assignedTo != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    // Assign button
                    GestureDetector(
                      onTap: () => _showAssignSheet(context, ticket),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _indigoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Assign',
                          style: TextStyle(
                            fontSize: 12,
                            color: _indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            _filterStatus == null
                ? 'Belum ada tiket'
                : 'Tidak ada tiket ${_filterStatus!.label}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151)),
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

  // ── Assign bottom sheet ───────────────────────────────────────────────────
  void _showAssignSheet(BuildContext context, TicketModel ticket) {
    final controller = TextEditingController(text: ticket.assignedTo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Assign Tiket',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(ticket.title,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nama admin / petugas',
                  prefixIcon:
                      const Icon(Icons.person_outline, color: _indigo),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _indigo, width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context
                        .read<TicketProvider>()
                        .assignTicket(ticket.id, controller.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/ticket_history_model.dart';
import 'package:project_uts/core/constant/app_colors.dart';

class TicketTrackingScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketTrackingScreen({super.key, required this.ticket});

  @override
  State<TicketTrackingScreen> createState() => _TicketTrackingScreenState();
}

class _TicketTrackingScreenState extends State<TicketTrackingScreen> {
  static const _indigo = AppColors.primaryLight;
  static const _indigoLight = Color(0xFFE7EFFB);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => AppColors.surface(_isDark);
  Color get _cardBg => AppColors.card(_isDark);

  String? _helpdeskName(TicketProvider provider, String? assignedTo) {
    if (assignedTo == null) return null;

    final match = provider.helpdeskUsers.where((u) => u.id == assignedTo);

    return match.isNotEmpty ? match.first.name : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().loadHistory(widget.ticket.id);
      context.read<TicketProvider>().loadHelpdeskUsers();
    });
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'open':        return AppColors.statusOpen;
      case 'assigned':    return AppColors.statusAssigned;
      case 'inProgress':  return AppColors.statusInProgress;
      case 'closed':      return AppColors.statusClosed;
      default:            return _indigo;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'open':        return Icons.radio_button_unchecked_rounded;
      case 'assigned':    return Icons.assignment_turned_in_rounded;
      case 'inProgress':  return Icons.timelapse_rounded;
      case 'closed':      return Icons.lock_rounded;
      default:            return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'open':        return 'Open';
      case 'assigned':    return 'Assigned';
      case 'inProgress':  return 'In Progress';
      case 'closed':      return 'Closed';
      default:            return status ?? '-';
    }
  }

  Color _ticketStatusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return AppColors.statusOpen;
      case TicketStatus.assigned:   return AppColors.statusAssigned;
      case TicketStatus.inProgress: return AppColors.statusInProgress;
      case TicketStatus.closed:     return AppColors.statusClosed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final history = ticketProvider.history;
    final ticket = widget.ticket;
    final statusColor = _ticketStatusColor(ticket.status);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
      title: const Text(
          'Tracking Tiket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _indigo,
      foregroundColor: Colors.white,
      elevation: 0,
      ),
      body: ticketProvider.isLoadingHistory
          ? const Center(child: CircularProgressIndicator(color: _indigo))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ticket Info Card ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon(ticket.status.name),
                                    size: 12,
                                    color: statusColor,
                                  ),
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
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(ticket.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ticket.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ticket.assignedTo != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 14, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'Ditangani: ${_helpdeskName(ticketProvider, ticket.assignedTo) ?? "Belum ditugaskan"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _indigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Timeline header ─────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Riwayat Perubahan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _indigoLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${history.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _indigo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Timeline ────────────────────────────────────────
                  history.isEmpty
                      ? _buildEmptyState()
                      : _buildTimeline(history),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeline(List<TicketHistoryModel> history) {
    return Column(
      children: List.generate(history.length, (index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        final color = _statusColor(item.newStatus);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline line & dot ──────────────────────────────
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(
                        _statusIcon(item.newStatus),
                        size: 14,
                        color: color,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Content ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action
                        Text(
                          item.action,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Status change
                        if (item.oldStatus != null &&
                            item.newStatus != null)
                          Row(
                            children: [
                              _statusPill(item.oldStatus),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward_rounded,
                                    size: 12, color: Colors.grey),
                              ),
                              _statusPill(item.newStatus),
                            ],
                          ),

                        const SizedBox(height: 8),

                        // User & time
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              item.userName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time_rounded,
                                size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM, HH:mm')
                                  .format(item.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusPill(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _indigoLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded,
                size: 40, color: _indigo),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Perubahan status akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
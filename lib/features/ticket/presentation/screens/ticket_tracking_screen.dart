import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class TicketTrackingScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketTrackingScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketTrackingScreen> createState() =>
      _TicketTrackingScreenState();
}

class _TicketTrackingScreenState
    extends State<TicketTrackingScreen> {

  final List<TicketStatus> _stages = [
    TicketStatus.open,
    TicketStatus.inProgress,
    TicketStatus.resolved,
    TicketStatus.closed,
  ];

  int _currentStageIndex(TicketStatus status) {
    final index = _stages.indexOf(status);
    return index == -1 ? 0 : index; // fallback biar aman
  }

  Color _stageColor(int stageIndex, int currentIndex) {
    if (stageIndex < currentIndex) return Colors.green;
    if (stageIndex == currentIndex) return Colors.blue;
    return Colors.grey.shade300;
  }

  IconData _stageIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.radio_button_unchecked;
      case TicketStatus.inProgress:
        return Icons.sync;
      case TicketStatus.resolved:
        return Icons.check_circle_outline;
      case TicketStatus.closed:
        return Icons.cancel_outlined;
    }
  }

  String _stageDescription(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Tiket telah dibuat dan menunggu ditangani';
      case TicketStatus.inProgress:
        return 'Tiket sedang ditangani oleh helpdesk';
      case TicketStatus.resolved:
        return 'Masalah telah diselesaikan';
      case TicketStatus.closed:
        return 'Tiket telah ditutup';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ticket = widget.ticket;
    final currentIndex = _currentStageIndex(ticket.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking — ${ticket.id}'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // INFO TIKET
            // =========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Dibuat: ${DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.5),
                    ),
                  ),

                  if (ticket.assignedTo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ditangani oleh: ${ticket.assignedTo}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Status Penanganan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TIMELINE TRACKING
            // =========================
            ...List.generate(_stages.length, (i) {
              final stage = _stages[i];
              final isDone = i < currentIndex;
              final isCurrent = i == currentIndex;
              final isPending = i > currentIndex;
              final color = _stageColor(i, currentIndex);
              final isLast = i == _stages.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ICON + LINE
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.grey.shade100
                              : isCurrent
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPending
                                ? Colors.grey.shade300
                                : isCurrent
                                    ? Colors.blue
                                    : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isDone ? Icons.check : _stageIcon(stage),
                          color: color,
                          size: 20,
                        ),
                      ),

                      if (!isLast)
                        Container(
                          width: 2,
                          height: 48,
                          color: isDone
                              ? Colors.green
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // TEXT
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 48),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.label,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPending
                                  ? theme.colorScheme.onSurface
                                      .withOpacity(0.4)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _stageDescription(stage),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: isPending
                                  ? theme.colorScheme.onSurface
                                      .withOpacity(0.3)
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                            ),
                          ),

                          if (isCurrent) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.blue.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Status saat ini',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
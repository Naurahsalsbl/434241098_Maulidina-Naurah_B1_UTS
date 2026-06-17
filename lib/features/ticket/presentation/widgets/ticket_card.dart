import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFFEF4444);
      case TicketStatus.inProgress:
        return const Color(0xFFF59E0B);
      case TicketStatus.resolved:
        return const Color(0xFF22C55E);
      case TicketStatus.closed:
        return Colors.grey;
    }
  }

  IconData _statusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.error_outline_rounded;
      case TicketStatus.inProgress:
        return Icons.sync_rounded;
      case TicketStatus.resolved:
        return Icons.check_circle_outline_rounded;
      case TicketStatus.closed:
        return Icons.lock_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = _statusColor(ticket.status);

    final ticketCode =
        'TKT-${ticket.id.substring(0, 4).toUpperCase()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: theme.colorScheme.surface,
              border: Border.all(
                color:
                    theme.colorScheme.outline.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticketCode,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              statusColor.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(ticket.status),
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              ticket.status.label,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // TITLE
                  Text(
                    ticket.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    ticket.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.65),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Divider(
                    color: theme.colorScheme.outline
                        .withOpacity(0.08),
                    height: 1,
                  ),

                  const SizedBox(height: 14),

                  // FOOTER
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.5),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        DateFormat(
                          'dd MMM yyyy • HH:mm',
                        ).format(ticket.createdAt),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.55),
                        ),
                      ),

                      const Spacer(),

                      if (ticket.assignedTo != null)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme
                                .secondaryContainer,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ticket.assignedTo!,
                                style: theme
                                    .textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
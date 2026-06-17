import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';

class TicketStatsWidget extends StatelessWidget {
  const TicketStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // =========================
        // TOTAL TICKET CARD
        // =========================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF64748B),
                Color(0xFF475569),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tiket',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      provider.totalTickets.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // =========================
        // STATUS GRID
        // =========================
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Open',
                value: provider
                    .countByStatus(TicketStatus.open)
                    .toString(),
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Progress',
                value: provider
                    .countByStatus(TicketStatus.inProgress)
                    .toString(),
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Resolved',
                value: provider
                    .countByStatus(TicketStatus.resolved)
                    .toString(),
                color: const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Closed',
                value: provider
                    .countByStatus(TicketStatus.closed)
                    .toString(),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  IconData get icon {
    switch (title) {
      case 'Open':
        return Icons.error_outline_rounded;
      case 'Progress':
        return Icons.pending_outlined;
      case 'Resolved':
        return Icons.check_circle_outline_rounded;
      case 'Closed':
        return Icons.lock_outline_rounded;
      default:
        return Icons.bar_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
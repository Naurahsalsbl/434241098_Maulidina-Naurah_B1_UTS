import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class TicketStatsWidget extends StatelessWidget {
  const TicketStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Tiket',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // TOTAL
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue, size: 28),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.totalTickets.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Total Tiket'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // STATUS GRID
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Open',
                value: provider.countByStatus(TicketStatus.open).toString(),
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Progress',
                value: provider
                    .countByStatus(TicketStatus.inProgress)
                    .toString(),
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Resolved',
                value: provider
                    .countByStatus(TicketStatus.resolved)
                    .toString(),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
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

// =========================
// 🔹 CARD KECIL
// =========================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}
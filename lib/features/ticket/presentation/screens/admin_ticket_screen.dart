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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final user = auth.user;

      if (user != null) {
        context.read<TicketProvider>().loadTickets(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();

    final tickets = ticketProvider.tickets;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Manajemen Tiket"),
      ),

      body: tickets.isEmpty
          ? const Center(child: Text("Belum ada tiket"))
          : ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(ticket.title),
                    subtitle: Text(ticket.status.name),

                    // =========================
                    // STATUS UPDATE ADMIN
                    // =========================
                    trailing: PopupMenuButton<TicketStatus>(
                      onSelected: (status) {
                        ticketProvider.updateTicketStatus(
                          ticket.id,
                          status,
                        );
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: TicketStatus.open,
                          child: Text('Open'),
                        ),
                        PopupMenuItem(
                          value: TicketStatus.inProgress,
                          child: Text('In Progress'),
                        ),
                        PopupMenuItem(
                          value: TicketStatus.resolved,
                          child: Text('Resolved'),
                        ),
                        PopupMenuItem(
                          value: TicketStatus.closed,
                          child: Text('Closed'),
                        ),
                      ],
                    ),

                    // =========================
                    // TAP = ASSIGN
                    // =========================
                    onTap: () {
                      _showAssignDialog(context, ticket);
                    },
                  ),
                );
              },
            ),
    );
  }

  // =========================
  // ASSIGN DIALOG (FIXED)
  // =========================
  void _showAssignDialog(BuildContext context, TicketModel ticket) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Assign Ticket"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Nama admin/petugas",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TicketProvider>().assignTicket(
                    ticket.id,
                    controller.text,
                  );

              Navigator.pop(context);
            },
            child: const Text("Assign"),
          ),
        ],
      ),
    );
  }
}
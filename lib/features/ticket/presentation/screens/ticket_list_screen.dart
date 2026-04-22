import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_uts/features/ticket/presentation/widgets/ticket_card.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/presentation/screens/ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    'Semua',
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final ticketProvider = context.read<TicketProvider>();
      final user = auth.user;

      // ✅ hanya load kalau masih kosong
      if (user != null && ticketProvider.tickets.isEmpty) {
        ticketProvider.loadTickets(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TicketModel> _filterTickets(List<TicketModel> all, int tabIndex) {
    if (tabIndex == 0) return all;

    final statuses = [
      TicketStatus.open,
      TicketStatus.open,
      TicketStatus.inProgress,
      TicketStatus.resolved,
      TicketStatus.closed,
    ];

    return all.where((t) => t.status == statuses[tabIndex]).toList();
  }

  void _loadTickets() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    if (user != null) {
      context.read<TicketProvider>().loadTickets(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    // =========================
    // LOGIN CHECK
    // =========================
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Login dulu")),
      );
    }

    final tickets = ticketProvider.tickets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: ticketProvider.isLoadingTickets
          ? const Center(child: CircularProgressIndicator())

          // ❌ FIX: tidak boleh pakai "!= null" atau ".isEmpty !"
          : tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum ada tiket"),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadTickets,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )

              : TabBarView(
                  controller: _tabController,
                  children: List.generate(_tabs.length, (tabIndex) {
                    final filtered = _filterTickets(tickets, tabIndex);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada tiket ${_tabs[tabIndex]}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadTickets(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => TicketCard(
                          ticket: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                             MaterialPageRoute(
                              builder: (_) => TicketDetailScreen(
                                ticket: filtered[i],
                              ),
                             ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/create-ticket'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Tiket'),
      ),

      // =========================
      // BOTTOM NAV
      // =========================
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notif',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          if (index == 1) {
            // tiket (posisi sekarang) → biasanya ga perlu apa-apa
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/notification'); // 🔔 notif
          }
          if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
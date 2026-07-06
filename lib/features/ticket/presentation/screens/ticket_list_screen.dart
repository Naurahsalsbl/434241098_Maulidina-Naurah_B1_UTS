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
    'Assigned',
    'In Progress',
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

      // Selalu load ulang sesuai role yang sedang login — JANGAN cuma
      // load "kalau list kosong", karena TicketProvider adalah singleton
      // yang tetap hidup lintas sesi login/logout. Kalau role sebelumnya
      // (mis. Admin) sudah mengisi _tickets, maka _tickets.isEmpty jadi
      // false dan role baru (mis. Helpdesk) tidak akan pernah fetch data
      // miliknya sendiri — ujung-ujungnya menampilkan data basi/kosong
      // dari sesi role sebelumnya.
      if (user != null) {
        _loadTicketsFor(user.role, user.id);
      }
      // Perlu daftar Helpdesk untuk menampilkan nama petugas (bukan id) di kartu tiket
      ticketProvider.loadHelpdeskUsers();
    });
  }

  void _loadTicketsFor(String role, String userId) {
    final ticketProvider = context.read<TicketProvider>();
    if (role == 'admin') {
      ticketProvider.loadAllTickets();
    } else if (role == 'helpdesk') {
      ticketProvider.loadAssignedTickets(userId);
    } else {
      ticketProvider.loadTickets(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Resolve id assigned_to menjadi nama Helpdesk yang bisa dibaca
  String? _helpdeskName(TicketProvider provider, String? assignedTo) {
    if (assignedTo == null) return null;
    final match = provider.helpdeskUsers.where((u) => u.id == assignedTo);
    return match.isNotEmpty ? match.first.name : null;
  }

  List<TicketModel> _filterTickets(List<TicketModel> all, int tabIndex) {
    if (tabIndex == 0) return all;

    final statuses = [
      TicketStatus.open, // index 0 tidak dipakai (tab "Semua" sudah return di atas)
      TicketStatus.open,
      TicketStatus.assigned,
      TicketStatus.inProgress,
      TicketStatus.closed,
    ];

    return all.where((t) => t.status == statuses[tabIndex]).toList();
  }

  void _loadTickets() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    if (user != null) {
      _loadTicketsFor(user.role, user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // =========================
    // LOGIN CHECK
    // =========================
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Login dulu")),
      );
    }

    final tickets = ticketProvider.tickets;

    String _appBarTitle() {
      switch (user.role) {
        case 'admin':
          return 'Semua Tiket';
        case 'helpdesk':
          return 'Tiket Ditugaskan';
        default:
          return 'Tiket Saya';
      }
    }

      return Scaffold(

  body: Column(
    children: [

      // HEADER
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
          child: Column(
            children: [

              const SizedBox(height: 8),

              Row(
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      _appBarTitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 16),

              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      Expanded(
        child: ticketProvider.isLoadingTickets
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum ada tiket"),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadTickets,
                          child: const Text("Refresh"),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(
                      _tabs.length,
                      (tabIndex) {
                        final filtered =
                            _filterTickets(tickets, tabIndex);

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              "Tidak ada tiket ${_tabs[tabIndex]}",
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
                              assignedToName: _helpdeskName(
                                ticketProvider,
                                filtered[i].assignedTo,
                              ),
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
                      },
                    ),
                  ),
      ),
    ],
  ),

      // =========================
      // FLOATING BUTTON — semua role boleh membuat tiket (sesuai SRS)
      // =========================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
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
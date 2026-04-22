import 'package:flutter/foundation.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';

class TicketProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  List<String> _comments = [];

  List<String> get comments => _comments;

  void addComment(String comment) {
  _comments.add(comment);
  notifyListeners();
  }

  bool _isLoadingTickets = false;
  bool _isCreating = false;
  bool _isUpdating = false;

  List<TicketModel> get tickets => _tickets;
  bool get isLoadingTickets => _isLoadingTickets;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;

  // =========================
  // LOAD DUMMY TICKETS
  // =========================
  Future<void> loadTickets(String userId) async {
    _isLoadingTickets = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _tickets = [
      TicketModel(
        id: '1',
        title: 'Wifi tidak konek',
        description: 'Internet kampus mati',
        status: TicketStatus.open,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TicketModel(
        id: '2',
        title: 'Laptop blue screen',
        description: 'Error terus',
        status: TicketStatus.inProgress,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _isLoadingTickets = false;
    notifyListeners();
  }

  // =========================
  // CREATE (DUMMY)
  // =========================
  Future<bool> createTicket({
    required String userId,
    required String title,
    required String description,
  }) async {
    _isCreating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final newTicket = TicketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: TicketStatus.open,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _tickets.insert(0, newTicket);

    _isCreating = false;
    notifyListeners();
    return true;
  }

  // =========================
  // UPDATE STATUS (ADMIN)
  // =========================
  void updateTicketStatus(String ticketId, TicketStatus status) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);

    if (index != -1) {
      _tickets[index] = TicketModel(
        id: _tickets[index].id,
        title: _tickets[index].title,
        description: _tickets[index].description,
        status: status,
        userId: _tickets[index].userId,
        assignedTo: _tickets[index].assignedTo,
        createdAt: _tickets[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // =========================
  // ASSIGN (DUMMY)
  // =========================
  void assignTicket(String ticketId, String assignee) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);

    if (index != -1) {
      _tickets[index] = _tickets[index].copyWith(
        assignedTo: assignee,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }



  // =========================
  // STATISTICS
  // =========================
  int get totalTickets => _tickets.length;

  int get openCount =>
      _tickets.where((t) => t.status == TicketStatus.open).length;

  int get inProgressCount =>
      _tickets.where((t) => t.status == TicketStatus.inProgress).length;

  int get resolvedCount =>
      _tickets.where((t) => t.status == TicketStatus.resolved).length;

  int get closedCount =>
      _tickets.where((t) => t.status == TicketStatus.closed).length;

  int countByStatus(TicketStatus status) {
  return _tickets.where((t) => t.status == status).length;
}
}
import 'package:flutter/foundation.dart';
import 'package:project_uts/features/ticket/data/ticket_repository.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';

class TicketProvider extends ChangeNotifier {
  final _repository = TicketRepository();

  List<TicketModel> _tickets = [];
  List<CommentModel> _comments = [];
  String? _errorMessage;

  bool _isLoadingTickets = false;
  bool _isLoadingComments = false;
  bool _isCreating = false;
  bool _isUpdating = false;

  List<TicketModel> get tickets => _tickets;
  List<CommentModel> get comments => _comments;
  String? get errorMessage => _errorMessage;
  bool get isLoadingTickets => _isLoadingTickets;
  bool get isLoadingComments => _isLoadingComments;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;

  // =========================
  // LOAD TICKETS (user)
  // =========================
  Future<void> loadTickets(String userId) async {
    _isLoadingTickets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await _repository.getTickets(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat tiket';
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD ALL TICKETS (admin/helpdesk)
  // =========================
  Future<void> loadAllTickets() async {
    _isLoadingTickets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await _repository.getAllTickets();
    } catch (e) {
      _errorMessage = 'Gagal memuat semua tiket';
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // =========================
  // CREATE TICKET
  // =========================
  Future<bool> createTicket({
    required String userId,
    required String title,
    required String description,
    String? filePath,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTicket = await _repository.createTicket(
        userId: userId,
        title: title,
        description: description,
        filePath: filePath,
      );
      _tickets.insert(0, newTicket);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat tiket';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE STATUS (admin/helpdesk)
  // =========================
  Future<void> updateTicketStatus(
      String ticketId, TicketStatus status) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updated = await _repository.updateTicketStatus(ticketId, status);
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) _tickets[index] = updated;
    } catch (e) {
      _errorMessage = 'Gagal update status';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // =========================
  // ASSIGN TICKET
  // =========================
  Future<void> assignTicket(String ticketId, String assignedTo) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updated = await _repository.assignTicket(ticketId, assignedTo);
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) _tickets[index] = updated;
    } catch (e) {
      _errorMessage = 'Gagal assign tiket';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD COMMENTS
  // =========================
  Future<void> loadComments(String ticketId) async {
    _isLoadingComments = true;
    notifyListeners();

    try {
      _comments = await _repository.getComments(ticketId);
    } catch (e) {
      _errorMessage = 'Gagal memuat komentar';
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  // =========================
  // ADD COMMENT
  // =========================
  Future<bool> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    try {
      final comment = await _repository.addComment(
        ticketId: ticketId,
        userId: userId,
        userName: userName,
        message: message,
      );
      _comments.add(comment);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim komentar';
      notifyListeners();
      return false;
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

  int countByStatus(TicketStatus status) =>
      _tickets.where((t) => t.status == status).length;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
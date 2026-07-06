import 'package:flutter/foundation.dart';
import 'package:project_uts/features/ticket/data/ticket_repository.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';
import 'package:project_uts/features/ticket/domain/ticket_history_model.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';
import 'package:project_uts/features/notification/presentation/providers/notification_provider.dart';

class TicketProvider extends ChangeNotifier {
  final _repository = TicketRepository();

  List<TicketModel> _tickets = [];
  List<CommentModel> _comments = [];
  List<TicketHistoryModel> _history = [];
  List<UserModel> _helpdeskUsers = [];
  String? _errorMessage;

  bool _isLoadingTickets = false;
  bool _isLoadingComments = false;
  bool _isLoadingHistory = false;
  bool _isLoadingHelpdeskUsers = false;
  bool _isCreating = false;
  bool _isUpdating = false;

  List<TicketModel> get tickets => _tickets;
  List<CommentModel> get comments => _comments;
  List<TicketHistoryModel> get history => _history;
  List<UserModel> get helpdeskUsers => _helpdeskUsers;
  String? get errorMessage => _errorMessage;
  bool get isLoadingTickets => _isLoadingTickets;
  bool get isLoadingComments => _isLoadingComments;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingHelpdeskUsers => _isLoadingHelpdeskUsers;
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
  // LOAD ASSIGNED TICKETS (helpdesk)
  // =========================
  Future<void> loadAssignedTickets(String helpdeskId) async {
    _isLoadingTickets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await _repository.getAssignedTickets(helpdeskId);
    } catch (e) {
      _errorMessage = 'Gagal memuat tiket yang ditugaskan';
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

      // Kirim notifikasi ke user (pembuat tiket)
      await NotificationProvider.sendNotification(
        userId: userId,
        title: 'Tiket Dibuat',
        message: 'Tiket "$title" berhasil dibuat',
        ticketId: newTicket.id,
      );

      // Kirim notifikasi ke semua Admin — supaya mereka tahu ada tiket baru masuk
      try {
        final adminIds = await _repository.getAdminUserIds();
        for (final adminId in adminIds) {
          await NotificationProvider.sendNotification(
            userId: adminId,
            title: 'Tiket Baru Masuk',
            message: 'Tiket "$title" perlu ditinjau',
            ticketId: newTicket.id,
          );
        }
      } catch (_) {
        // Kegagalan notifikasi ke Admin tidak boleh menggagalkan pembuatan tiket
      }

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
  // ACCEPT TICKET
  // =========================
  Future<void> acceptTicket(
    String ticketId, {
    String? userId,
    String? userName,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      final ticketUserId = index != -1 ? _tickets[index].userId : null;
      final ticketTitle = index != -1 ? _tickets[index].title : '';

      final updated = await _repository.acceptTicket(ticketId);

      if (index != -1) {
        _tickets[index] = updated;
      }

      if (userId != null && userName != null) {
        await _repository.addTicketHistory(
          ticketId: ticketId,
          userId: userId,
          userName: userName,
          action: 'Admin menerima tiket',
          oldStatus: 'open',
          newStatus: 'assigned',
        );
      }

      if (ticketUserId != null) {
        await NotificationProvider.sendNotification(
          userId: ticketUserId,
          title: 'Tiket Diterima',
          message: 'Tiket "$ticketTitle" telah diterima Admin',
          ticketId: ticketId,
        );
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

    // =========================
    // ASSIGN TICKET
    // =========================
    Future<void> assignTicket(
      String ticketId,
      String assignedTo, {
      String? userId,
      String? userName,
    }) async {
      _isUpdating = true;
      notifyListeners();

      try {
        final index = _tickets.indexWhere((t) => t.id == ticketId);
        final ticketUserId = index != -1 ? _tickets[index].userId : null;
        final ticketTitle = index != -1 ? _tickets[index].title : '';

        final updated =
            await _repository.assignTicket(ticketId, assignedTo);

        if (index != -1) {
          _tickets[index] = updated;
        }

        if (userId != null && userName != null) {
          await _repository.addTicketHistory(
            ticketId: ticketId,
            userId: userId,
            userName: userName,
            action: 'Assign ke Helpdesk',
            oldStatus: 'assigned',
            newStatus: 'inProgress',
          );
        }

        if (ticketUserId != null) {
          await NotificationProvider.sendNotification(
            userId: ticketUserId,
            title: 'Tiket Diproses',
            message:
                'Tiket "$ticketTitle" sedang dikerjakan Helpdesk',
            ticketId: ticketId,
          );
        }

        // Notifikasi ke Helpdesk yang baru saja ditugaskan
        await NotificationProvider.sendNotification(
          userId: assignedTo,
          title: 'Tiket Baru Ditugaskan',
          message: 'Anda ditugaskan menangani tiket "$ticketTitle"',
          ticketId: ticketId,
        );
      } finally {
        _isUpdating = false;
        notifyListeners();
      }
    }

  // =========================
  // FINISH TICKET
  // =========================
  Future<void> finishTicket(
    String ticketId, {
    String? userId,
    String? userName,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      final ticketUserId = index != -1 ? _tickets[index].userId : null;
      final ticketTitle = index != -1 ? _tickets[index].title : '';

      final updated = await _repository.finishTicket(ticketId);

      if (index != -1) {
        _tickets[index] = updated;
      }

      if (userId != null && userName != null) {
        await _repository.addTicketHistory(
          ticketId: ticketId,
          userId: userId,
          userName: userName,
          action: 'Tiket selesai',
          oldStatus: 'inProgress',
          newStatus: 'closed',
        );
      }

      if (ticketUserId != null) {
        await NotificationProvider.sendNotification(
          userId: ticketUserId,
          title: 'Tiket Selesai',
          message:
              'Tiket "$ticketTitle" telah selesai dikerjakan',
          ticketId: ticketId,
        );
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD HELPDESK USERS (untuk Admin memilih penerima assign)
  // =========================
  Future<void> loadHelpdeskUsers() async {
    _isLoadingHelpdeskUsers = true;
    notifyListeners();

    try {
      _helpdeskUsers = await _repository.getHelpdeskUsers();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar helpdesk';
    } finally {
      _isLoadingHelpdeskUsers = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE TICKET
  // =========================
  Future<bool> deleteTicket(String ticketId) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return false;

    final backup = _tickets[index];
    _tickets.removeAt(index);
    notifyListeners();

    try {
      await _repository.deleteTicket(ticketId);
      return true;
    } catch (e) {
      // rollback kalau gagal
      _tickets.insert(index, backup);
      _errorMessage = 'Gagal menghapus tiket';
      notifyListeners();
      return false;
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
  // LOAD HISTORY
  // =========================
  Future<void> loadHistory(String ticketId) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _history = await _repository.getTicketHistory(ticketId);
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat';
    } finally {
      _isLoadingHistory = false;
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
  int get assignedCount =>
      _tickets.where((t) => t.status == TicketStatus.assigned).length;
  int get closedCount =>
      _tickets.where((t) => t.status == TicketStatus.closed).length;

  int countByStatus(TicketStatus status) =>
      _tickets.where((t) => t.status == status).length;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
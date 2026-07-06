import 'package:project_uts/features/ticket/data/ticket_remote_datasource.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';
import 'package:project_uts/features/ticket/domain/ticket_history_model.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';

class TicketRepository {
  final _datasource = TicketRemoteDatasource();

  // =========================
  // TICKETS
  // =========================

  Future<List<TicketModel>> getTickets(String userId) =>
      _datasource.getTickets(userId);

  Future<List<TicketModel>> getAllTickets() =>
      _datasource.getAllTickets();

  Future<List<TicketModel>> getAssignedTickets(String helpdeskId) =>
      _datasource.getAssignedTickets(helpdeskId);

  Future<TicketModel> getTicketDetail(String ticketId) =>
      _datasource.getTicketDetail(ticketId);

  Future<TicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
    String? filePath,
  }) =>
      _datasource.createTicket(
        userId: userId,
        title: title,
        description: description,
        filePath: filePath,
      );

  // =========================
  // WORKFLOW TIKET
  // =========================

  /// Admin menerima tiket
  Future<TicketModel> acceptTicket(String ticketId) =>
      _datasource.acceptTicket(ticketId);

  /// Admin assign ke helpdesk
  Future<TicketModel> assignTicket(
    String ticketId,
    String assignedTo,
  ) =>
      _datasource.assignTicket(
        ticketId,
        assignedTo,
      );

  /// Helpdesk menyelesaikan tiket
  Future<TicketModel> finishTicket(String ticketId) =>
      _datasource.finishTicket(ticketId);

  /// Admin menghapus tiket
  Future<void> deleteTicket(String ticketId) =>
      _datasource.deleteTicket(ticketId);

  // =========================
  // HELPDESK USERS
  // =========================

  Future<List<UserModel>> getHelpdeskUsers() => _datasource.getHelpdeskUsers();

  Future<List<String>> getAdminUserIds() => _datasource.getAdminUserIds();

  // =========================
  // COMMENTS
  // =========================

  Future<List<CommentModel>> getComments(String ticketId) =>
      _datasource.getComments(ticketId);

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) =>
      _datasource.addComment(
        ticketId: ticketId,
        userId: userId,
        userName: userName,
        message: message,
      );

  // =========================
  // HISTORY
  // =========================

  Future<List<TicketHistoryModel>> getTicketHistory(
    String ticketId,
  ) =>
      _datasource.getTicketHistory(ticketId);

  Future<void> addTicketHistory({
    required String ticketId,
    required String userId,
    required String userName,
    required String action,
    String? oldStatus,
    String? newStatus,
  }) =>
      _datasource.addTicketHistory(
        ticketId: ticketId,
        userId: userId,
        userName: userName,
        action: action,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );
}
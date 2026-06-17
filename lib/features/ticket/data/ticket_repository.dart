import 'package:project_uts/features/ticket/data/ticket_remote_datasource.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';

class TicketRepository {
  final _datasource = TicketRemoteDatasource();

  Future<List<TicketModel>> getTickets(String userId) =>
      _datasource.getTickets(userId);

  Future<List<TicketModel>> getAllTickets() =>
      _datasource.getAllTickets();

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

  Future<TicketModel> updateTicketStatus(
          String ticketId, TicketStatus status) =>
      _datasource.updateTicketStatus(ticketId, status);

  Future<TicketModel> assignTicket(String ticketId, String assignedTo) =>
      _datasource.assignTicket(ticketId, assignedTo);

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
}
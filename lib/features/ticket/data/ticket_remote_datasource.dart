import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';
import 'package:project_uts/features/ticket/domain/ticket_history_model.dart';
import 'package:project_uts/features/auth/domain/user_model.dart';
import 'package:project_uts/core/constant/api_endpoints.dart';
import 'package:project_uts/core/network/supabase_client.dart';

class TicketRemoteDatasource {
  final _client = SupabaseClientHelper.client;

  // =========================
  // GET TICKETS (user)
  // =========================
  Future<List<TicketModel>> getTickets(String userId) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  // =========================
  // GET ALL TICKETS (admin/helpdesk)
  // =========================
  Future<List<TicketModel>> getAllTickets() async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  // =========================
  // GET ASSIGNED TICKETS (helpdesk)
  // =========================
  Future<List<TicketModel>> getAssignedTickets(String helpdeskId) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .select()
        .eq('assigned_to', helpdeskId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  // =========================
  // DELETE TICKET
  // =========================
  Future<void> deleteTicket(String ticketId) async {
    // Hapus data terkait dulu (jaga-jaga kalau FK belum ON DELETE CASCADE)
    await _client.from(ApiEndpoints.commentsTable).delete().eq('ticket_id', ticketId);
    await _client.from(ApiEndpoints.ticketHistoryTable).delete().eq('ticket_id', ticketId);
    await _client.from(ApiEndpoints.notificationsTable).delete().eq('ticket_id', ticketId);
    await _client.from(ApiEndpoints.ticketsTable).delete().eq('id', ticketId);
  }

  // =========================
  // GET DETAIL TICKET
  // =========================
  Future<TicketModel> getTicketDetail(String ticketId) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .select()
        .eq('id', ticketId)
        .single();

    return TicketModel.fromJson(response);
  }

  // =========================
  // CREATE TICKET
  // =========================
  Future<TicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
    String? filePath,
  }) async {
    String? fileUrl;

    // Upload file jika ada
    if (filePath != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';

      await _client.storage
          .from(ApiEndpoints.attachmentsBucket)
          .upload(fileName, File(filePath));

      fileUrl = _client.storage
          .from(ApiEndpoints.attachmentsBucket)
          .getPublicUrl(fileName);
    }

    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .insert({
          'title': title,
          'description': description,
          'status': 'open',
          'user_id': userId,
          'attachment_url': fileUrl,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return TicketModel.fromJson(response);
  }

  // =========================
  // ACCEPT STATUS
  // =========================
  Future<TicketModel> acceptTicket(String ticketId) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .update({
          'status': 'assigned',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId)
        .select()
        .single();

    return TicketModel.fromJson(response);
  }

  // =========================
  // ASSIGN TICKET
  // =========================
  Future<TicketModel> assignTicket(
      String ticketId,
      String assignedTo,
  ) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .update({
          'assigned_to': assignedTo,
          'status': 'inProgress',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId)
        .select()
        .single();

    return TicketModel.fromJson(response);
  }

  // =========================
  // GET HELPDESK USERS (untuk Admin memilih penerima assign)
  // =========================
  Future<List<UserModel>> getHelpdeskUsers() async {
    final response = await _client
        .from(ApiEndpoints.usersTable)
        .select()
        .eq('role', 'helpdesk')
        .order('name', ascending: true);

    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  // =========================
  // GET ADMIN USER IDS (untuk notifikasi tiket baru masuk)
  // =========================
  Future<List<String>> getAdminUserIds() async {
    final response = await _client
        .from(ApiEndpoints.usersTable)
        .select('id')
        .eq('role', 'admin');

    return (response as List).map((e) => e['id'] as String).toList();
  }

  // =========================
  // GET COMMENTS
  // =========================
  Future<List<CommentModel>> getComments(String ticketId) async {
    final response = await _client
        .from(ApiEndpoints.commentsTable)
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => CommentModel.fromJson(e)).toList();
  }

  // =========================
  // ADD COMMENT
  // =========================
  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final response = await _client
        .from(ApiEndpoints.commentsTable)
        .insert({
          'ticket_id': ticketId,
          'user_id': userId,
          'user_name': userName,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return CommentModel.fromJson(response);
  }

  // =========================
  // GET TICKET HISTORY
  // =========================
  Future<List<TicketHistoryModel>> getTicketHistory(String ticketId) async {
    final response = await _client
        .from(ApiEndpoints.ticketHistoryTable)
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => TicketHistoryModel.fromJson(e))
        .toList();
  }

  // =========================
  // ADD TICKET HISTORY
  // =========================
  Future<void> addTicketHistory({
    required String ticketId,
    required String userId,
    required String userName,
    required String action,
    String? oldStatus,
    String? newStatus,
  }) async {
    await _client.from(ApiEndpoints.ticketHistoryTable).insert({
      'ticket_id': ticketId,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'old_status': oldStatus,
      'new_status': newStatus,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // =========================
  // FINISH TICKET
  // =========================  
  Future<TicketModel> finishTicket(String ticketId) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .update({
          'status': 'closed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId)
        .select()
        .single();

    return TicketModel.fromJson(response);
  }
}
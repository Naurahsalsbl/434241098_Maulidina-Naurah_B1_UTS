import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';
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
  // UPDATE STATUS
  // =========================
  Future<TicketModel> updateTicketStatus(
      String ticketId, TicketStatus status) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .update({
          'status': status.name,
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
      String ticketId, String assignedTo) async {
    final response = await _client
        .from(ApiEndpoints.ticketsTable)
        .update({
          'assigned_to': assignedTo,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId)
        .select()
        .single();

    return TicketModel.fromJson(response);
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
}
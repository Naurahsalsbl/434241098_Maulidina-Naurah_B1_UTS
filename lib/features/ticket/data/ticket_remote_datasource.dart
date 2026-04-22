import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/features/ticket/domain/ticket_model.dart';
import 'package:project_uts/features/ticket/domain/comment_model.dart';

class TicketRemoteDatasource {
  final supabase = Supabase.instance.client;

  // =========================
  // 📋 GET ALL TICKETS
  // =========================
  Future<List<TicketModel>> getTickets(String userId) async {
    final response = await supabase
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => TicketModel.fromJson(e))
        .toList();
  }

  // =========================
  // 👀 GET DETAIL TICKET
  // =========================
  Future<TicketModel> getTicketDetail(String ticketId) async {
    final response = await supabase
        .from('tickets')
        .select()
        .eq('id', ticketId)
        .single();

    return TicketModel.fromJson(response);
  }

  // =========================
  // ➕ CREATE TICKET
  // =========================
  Future<TicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
    String? filePath,
  }) async {
    String? fileUrl;

    // =========================
    // 📤 UPLOAD FILE (OPTIONAL)
    // =========================
    if (filePath != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';

      await supabase.storage
          .from('tickets')
          .upload(fileName, File(filePath));

      fileUrl = supabase.storage
          .from('tickets')
          .getPublicUrl(fileName);
    }

    final response = await supabase
        .from('tickets')
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
  // 💬 GET COMMENTS
  // =========================
  Future<List<CommentModel>> getComments(String ticketId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => CommentModel.fromJson(e))
        .toList();
  }

  // =========================
  // ➕ ADD COMMENT
  // =========================
  Future<CommentModel> addComment({
    required String ticketId,
    required String message,
    required String userId,
  }) async {
    final response = await supabase
        .from('comments')
        .insert({
          'ticket_id': ticketId,
          'message': message,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return CommentModel.fromJson(response);
  }
}
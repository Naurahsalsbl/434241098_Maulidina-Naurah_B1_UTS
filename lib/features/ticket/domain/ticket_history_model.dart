class TicketHistoryModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String action;
  final String? oldStatus;
  final String? newStatus;
  final DateTime createdAt;

  const TicketHistoryModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.action,
    this.oldStatus,
    this.newStatus,
    required this.createdAt,
  });

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) {
    return TicketHistoryModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? '',
      action: json['action'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
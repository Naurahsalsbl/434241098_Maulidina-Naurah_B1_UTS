class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? '',
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'user_name': userName,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
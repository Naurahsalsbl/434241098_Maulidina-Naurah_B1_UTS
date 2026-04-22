class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.ticketId,
    this.isRead = false,
    required this.createdAt,
  });

  // =========================
  // COPY WITH (WAJIB UNTUK STATE)
  // =========================
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? ticketId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      ticketId: ticketId ?? this.ticketId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
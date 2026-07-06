enum TicketStatus { open, assigned, inProgress, closed }

extension TicketStatusExt on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String get emoji {
    switch (this) {
      case TicketStatus.open:
        return '🔴';
      case TicketStatus.assigned:
        return '🟡';
      case TicketStatus.inProgress:
        return '🟢';
      case TicketStatus.closed:
        return '⚫';
    }
  }
}

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final String userId;
  final String? assignedTo;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
    this.assignedTo,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      userId: json['user_id'] as String? ?? '',
      assignedTo: json['assigned_to'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    TicketStatus? status,
    String? userId,
    String? assignedTo,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      assignedTo: assignedTo ?? this.assignedTo,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
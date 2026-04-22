enum TicketStatus { open, inProgress, resolved, closed }

extension TicketStatusExt on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String get emoji {
    switch (this) {
      case TicketStatus.open:
        return '🔴';
      case TicketStatus.inProgress:
        return '🟡';
      case TicketStatus.resolved:
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  // =========================
  // JSON FROM SUPABASE
  // =========================
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      userId: json['user_id'] as String,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // =========================
  // COPY WITH (FIX ERROR KAMU)
  // =========================
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    TicketStatus? status,
    String? userId,
    String? assignedTo,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
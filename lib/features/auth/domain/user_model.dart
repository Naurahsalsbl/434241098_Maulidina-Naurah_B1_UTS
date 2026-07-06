class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'] as String?,
      isActive: json['is_active'] ?? true,
    );
  }

  UserModel copyWith({
    String? role,
    String? name,
    String? email,
    String? avatar,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isHelpdesk => role == 'helpdesk' || role == 'admin';
  bool get isUser => role == 'user';
}
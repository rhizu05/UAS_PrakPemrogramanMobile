class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Role can be a String (e.g., in Login response) or a Map (e.g., in Profile response)
    String parsedRole = 'customer';
    final roleData = json['role'];
    if (roleData is Map<String, dynamic>) {
      parsedRole = roleData['name'] ?? 'customer';
    } else if (roleData is String) {
      parsedRole = roleData;
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      role: parsedRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}

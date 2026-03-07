class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final bool isEmailVerified;
  final bool isArchived;
  final List<String> roles;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.isActive,
    required this.isEmailVerified,
    required this.isArchived,
    required this.roles,
    this.lastLoginAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isArchived: json['isArchived'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
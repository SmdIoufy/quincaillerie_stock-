class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.isBlocked,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firebaseUid: json['firebaseUid'],
      email: json['email'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  UserModel copyWith({
    String? role,
    String? displayName,
    bool? isActive,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

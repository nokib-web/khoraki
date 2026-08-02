class UserEntity {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? messId;
  final String role; // 'manager', 'member', or 'none'
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.messId,
    this.role = 'none',
    this.createdAt,
  });

  bool get hasJoinedMess => messId != null && messId!.isNotEmpty && role != 'none';

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? messId,
    String? role,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      messId: messId ?? this.messId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    super.displayName,
    super.messId,
    super.role = 'none',
    super.createdAt,
    super.lastSeenNoticeTimestamp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      displayName: json['displayName'] as String?,
      messId: json['messId'] as String?,
      role: json['role'] as String? ?? 'none',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      lastSeenNoticeTimestamp: json['lastSeenNoticeTimestamp'] != null
          ? DateTime.tryParse(json['lastSeenNoticeTimestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'messId': messId,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'lastSeenNoticeTimestamp': lastSeenNoticeTimestamp?.toIso8601String(),
    };
  }
}

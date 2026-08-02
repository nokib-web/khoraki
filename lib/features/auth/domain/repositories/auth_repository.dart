import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  });

  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserEntity?> getCurrentUserData();

  Future<UserEntity> createMess({
    required String messName,
    required String managerName,
  });

  Future<UserEntity> joinMess({
    required String inviteCode,
    required String memberName,
  });

  Future<void> signOut();
}

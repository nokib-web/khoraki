import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      state = const AuthLoading();
      final user = await _authRepository.getCurrentUserData();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = const Unauthenticated();
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthLoading();
    await _authRepository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        state = AuthCodeSent(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
        );
      },
      onError: (error) {
        state = AuthError(error);
      },
    );
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    try {
      state = const AuthLoading();
      final user = await _authRepository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> createMess(String messName, String managerName) async {
    try {
      state = const AuthLoading();
      final updatedUser = await _authRepository.createMess(
        messName: messName,
        managerName: managerName,
      );
      state = Authenticated(updatedUser);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> joinMess(String inviteCode, String memberName) async {
    try {
      state = const AuthLoading();
      final updatedUser = await _authRepository.joinMess(
        inviteCode: inviteCode,
        memberName: memberName,
      );
      state = Authenticated(updatedUser);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    await _authRepository.signOut();
    state = const Unauthenticated();
  }
}

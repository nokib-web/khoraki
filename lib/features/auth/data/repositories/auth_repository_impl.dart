import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth? _customAuth;
  final FirestoreService _firestoreService;
  final AuthService _authService;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _customAuth = firebaseAuth,
        _firestoreService = firestoreService ?? FirestoreService(),
        _authService = authService ?? AuthService();

  FirebaseAuth get _firebaseAuth {
    if (_customAuth != null) return _customAuth!;
    if (Firebase.apps.isNotEmpty) {
      return FirebaseAuth.instance;
    }
    throw Exception('Firebase is not initialized yet.');
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('User authentication failed.');
    }

    final userDocPath = FirestorePaths.user(user.uid);
    final docSnapshot = await _firestoreService.getDocument(userDocPath);

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromJson(docSnapshot.data()!);
    } else {
      final newUser = UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        role: 'none',
        createdAt: DateTime.now(),
      );
      await _firestoreService.setData(
        path: userDocPath,
        data: newUser.toJson(),
      );
      return newUser;
    }
  }

  @override
  Future<UserEntity?> getCurrentUserData() async {
    try {
      if (Firebase.apps.isEmpty) return null;
      final user = _authService.currentUser;
      if (user == null) return null;

      final docSnapshot = await _firestoreService.getDocument(FirestorePaths.user(user.uid));
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromJson(docSnapshot.data()!);
      }
      return UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        role: 'none',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> createMess({
    required String messName,
    required String managerName,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final messId = DateTime.now().millisecondsSinceEpoch.toString();
    final inviteCode = messId.substring(messId.length - 6).toUpperCase();

    final messData = {
      'id': messId,
      'name': messName,
      'managerId': currentUser.uid,
      'inviteCode': inviteCode,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _firestoreService.setData(
      path: FirestorePaths.household(messId),
      data: messData,
    );

    final updatedUser = UserModel(
      uid: currentUser.uid,
      phoneNumber: currentUser.phoneNumber ?? '',
      displayName: managerName,
      messId: messId,
      role: 'manager',
      createdAt: DateTime.now(),
    );

    await _firestoreService.setData(
      path: FirestorePaths.user(currentUser.uid),
      data: updatedUser.toJson(),
    );

    return updatedUser;
  }

  @override
  Future<UserEntity> joinMess({
    required String inviteCode,
    required String memberName,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final stream = _firestoreService.collectionStream(
      path: FirestorePaths.households,
      queryBuilder: (query) => query
          .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
          .limit(1),
    );

    final snapshot = await stream.first;

    if (snapshot.docs.isEmpty) {
      throw Exception('Invalid invite code. Mess not found.');
    }

    final messDoc = snapshot.docs.first;
    final messId = messDoc.id;

    final updatedUser = UserModel(
      uid: currentUser.uid,
      phoneNumber: currentUser.phoneNumber ?? '',
      displayName: memberName,
      messId: messId,
      role: 'member',
      createdAt: DateTime.now(),
    );

    await _firestoreService.setData(
      path: FirestorePaths.user(currentUser.uid),
      data: updatedUser.toJson(),
    );

    return updatedUser;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }
}

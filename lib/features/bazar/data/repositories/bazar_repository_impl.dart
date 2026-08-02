import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/bazar_entry_entity.dart';
import '../../domain/repositories/bazar_repository.dart';
import '../models/bazar_entry_model.dart';

class BazarRepositoryImpl implements BazarRepository {
  final FirestoreService _firestoreService;
  final FirebaseStorage _firebaseStorage;

  BazarRepositoryImpl({
    FirestoreService? firestoreService,
    FirebaseStorage? firebaseStorage,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  String _collectionPath(String messId) => 'households/$messId/bazars';

  @override
  Stream<List<BazarEntryEntity>> watchMonthlyBazarEntries({
    required String messId,
    required int year,
    required int month,
  }) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return _firestoreService
        .collectionStream(
          path: _collectionPath(messId),
          queryBuilder: (query) => query
              .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
              .where('date', isLessThanOrEqualTo: endOfMonth.toIso8601String())
              .orderBy('date', descending: true),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => BazarEntryModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  @override
  Future<void> addBazarEntry({
    required String messId,
    required String userId,
    required String userName,
    required double amount,
    required DateTime date,
    String? note,
    String? localImagePath,
  }) async {
    String? receiptUrl;

    if (localImagePath != null && localImagePath.isNotEmpty) {
      final file = File(localImagePath);
      if (await file.exists()) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _firebaseStorage
            .ref()
            .child('households/$messId/bazar_receipts/$fileName');
        final uploadTask = await storageRef.putFile(file);
        receiptUrl = await uploadTask.ref.getDownloadURL();
      }
    }

    final docId = DateTime.now().millisecondsSinceEpoch.toString();

    final model = BazarEntryModel(
      id: docId,
      messId: messId,
      createdByUserId: userId,
      createdByUserName: userName,
      amount: amount,
      date: date,
      note: note,
      receiptUrl: receiptUrl,
      createdAt: DateTime.now(),
    );

    await _firestoreService.setData(
      path: '${_collectionPath(messId)}/$docId',
      data: model.toJson(),
    );
  }
}

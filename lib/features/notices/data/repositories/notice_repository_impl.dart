import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notice_repository.dart';
import '../models/notice_model.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  final FirestoreService _firestoreService;

  NoticeRepositoryImpl({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  String _collectionPath(String messId) => 'households/$messId/notices';

  @override
  Stream<List<NoticeEntity>> watchMessNotices({required String messId}) {
    return _firestoreService
        .collectionStream(
          path: _collectionPath(messId),
          queryBuilder: (query) => query.orderBy('createdAt', descending: true),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => NoticeModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  @override
  Future<void> postNotice({
    required String messId,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
  }) async {
    final docRef = FirebaseFirestore.instance.collection(_collectionPath(messId)).doc();

    final model = NoticeModel(
      id: docRef.id,
      messId: messId,
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    await _firestoreService.setData(
      path: '${_collectionPath(messId)}/${docRef.id}',
      data: model.toJson(),
    );
  }

  @override
  Future<void> updateLastSeenNoticeTimestamp({
    required String userId,
    required DateTime timestamp,
  }) async {
    await _firestoreService.setData(
      path: FirestorePaths.user(userId),
      data: {
        'lastSeenNoticeTimestamp': timestamp.toIso8601String(),
      },
      merge: true,
    );
  }
}

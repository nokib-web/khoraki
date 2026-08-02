import '../entities/notice_entity.dart';

abstract class NoticeRepository {
  Stream<List<NoticeEntity>> watchMessNotices({required String messId});

  Future<void> postNotice({
    required String messId,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
  });

  Future<void> updateLastSeenNoticeTimestamp({
    required String userId,
    required DateTime timestamp,
  });
}

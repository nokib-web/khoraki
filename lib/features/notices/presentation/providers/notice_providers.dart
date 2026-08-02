import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepositoryImpl();
});

final messNoticesStreamProvider =
    StreamProvider.family<List<NoticeEntity>, String>((ref, messId) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.watchMessNotices(messId: messId);
});

final unreadNoticeCountProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.messId == null) return 0;

  final noticesAsync = ref.watch(messNoticesStreamProvider(user!.messId!));
  final notices = noticesAsync.value ?? [];

  final lastSeen = user.lastSeenNoticeTimestamp;
  if (lastSeen == null) {
    return notices.length;
  }

  return notices.where((notice) => notice.createdAt.isAfter(lastSeen)).length;
});

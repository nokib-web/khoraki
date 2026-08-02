import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/notice_providers.dart';
import '../widgets/post_notice_dialog.dart';

class NoticesListScreen extends ConsumerStatefulWidget {
  const NoticesListScreen({super.key});

  @override
  ConsumerState<NoticesListScreen> createState() => _NoticesListScreenState();
}

class _NoticesListScreenState extends ConsumerState<NoticesListScreen> {
  @override
  void initState() {
    super.initState();
    // Mark notices as read when user views this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markNoticesAsRead();
    });
  }

  void _markNoticesAsRead() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(noticeRepositoryProvider).updateLastSeenNoticeTimestamp(
            userId: user.uid,
            timestamp: DateTime.now(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider);

    if (user?.messId == null) {
      return const Scaffold(
        body: Center(child: Text('Please join a mess to view notices.')),
      );
    }

    final isManager = role == 'manager';
    final noticesAsync = ref.watch(messNoticesStreamProvider(user!.messId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Notice Board'),
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const PostNoticeDialog(),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_comment, color: Colors.white),
              label: const Text('Post Notice', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: SafeArea(
        child: noticesAsync.when(
          data: (notices) {
            if (notices.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No notices posted yet.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                final formattedDate =
                    DateFormat('EEE, dd MMM yyyy • hh:mm a').format(notice.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.campaign, size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                notice.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          notice.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'By ${notice.authorName}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const LoadingIndicator(message: 'Loading notices...'),
          error: (err, stack) => Center(child: Text('Error loading notices: $err')),
        ),
      ),
    );
  }
}

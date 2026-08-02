class NoticeEntity {
  final String id;
  final String messId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;

  const NoticeEntity({
    required this.id,
    required this.messId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

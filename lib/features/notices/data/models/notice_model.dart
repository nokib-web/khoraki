import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  const NoticeModel({
    required super.id,
    required super.messId,
    required super.authorId,
    required super.authorName,
    required super.title,
    required super.content,
    required super.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return NoticeModel(
      id: docId ?? json['id'] as String? ?? '',
      messId: json['messId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Manager',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messId': messId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

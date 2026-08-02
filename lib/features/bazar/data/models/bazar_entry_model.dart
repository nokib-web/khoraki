import '../../domain/entities/bazar_entry_entity.dart';

class BazarEntryModel extends BazarEntryEntity {
  const BazarEntryModel({
    required super.id,
    required super.messId,
    required super.createdByUserId,
    required super.createdByUserName,
    required super.amount,
    required super.date,
    super.note,
    super.receiptUrl,
    super.createdAt,
  });

  factory BazarEntryModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return BazarEntryModel(
      id: docId ?? json['id'] as String? ?? '',
      messId: json['messId'] as String? ?? '',
      createdByUserId: json['createdByUserId'] as String? ?? '',
      createdByUserName: json['createdByUserName'] as String? ?? 'Manager',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messId': messId,
      'createdByUserId': createdByUserId,
      'createdByUserName': createdByUserName,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

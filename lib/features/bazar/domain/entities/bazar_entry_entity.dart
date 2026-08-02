class BazarEntryEntity {
  final String id;
  final String messId;
  final String createdByUserId;
  final String createdByUserName;
  final double amount;
  final DateTime date;
  final String? note;
  final String? receiptUrl;
  final DateTime? createdAt;

  const BazarEntryEntity({
    required this.id,
    required this.messId,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.amount,
    required this.date,
    this.note,
    this.receiptUrl,
    this.createdAt,
  });

  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;
}

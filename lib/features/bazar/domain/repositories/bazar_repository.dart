import '../entities/bazar_entry_entity.dart';

abstract class BazarRepository {
  Stream<List<BazarEntryEntity>> watchMonthlyBazarEntries({
    required String messId,
    required int year,
    required int month,
  });

  Future<void> addBazarEntry({
    required String messId,
    required String userId,
    required String userName,
    required double amount,
    required DateTime date,
    String? note,
    String? localImagePath,
  });
}

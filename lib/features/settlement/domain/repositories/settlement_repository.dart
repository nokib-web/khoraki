import '../../../../core/utils/meal_calculator.dart';
import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Stream<List<SettlementEntity>> watchMessSettlements({required String messId});

  Future<SettlementEntity?> getSettlementByYearMonth({
    required String messId,
    required String yearMonth,
  });

  Future<void> closeMonthAndSnapshot({
    required String messId,
    required String yearMonth,
    required String closedByUserId,
    required String closedByUserName,
    required MessMonthlyCalculation calc,
  });
}

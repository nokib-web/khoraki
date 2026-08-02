import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/meal_calculator.dart';
import '../../domain/entities/member_settlement_summary.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../models/settlement_model.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final FirestoreService _firestoreService;

  SettlementRepositoryImpl({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  String _collectionPath(String messId) => 'households/$messId/settlements';
  String _documentPath(String messId, String yearMonth) =>
      'households/$messId/settlements/$yearMonth';

  @override
  Stream<List<SettlementEntity>> watchMessSettlements({required String messId}) {
    return _firestoreService
        .collectionStream(
          path: _collectionPath(messId),
          queryBuilder: (query) => query.orderBy('closedAt', descending: true),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => SettlementModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  @override
  Future<SettlementEntity?> getSettlementByYearMonth({
    required String messId,
    required String yearMonth,
  }) async {
    final path = _documentPath(messId, yearMonth);
    final snapshot = await _firestoreService.getDocument(path);
    if (snapshot.exists && snapshot.data() != null) {
      return SettlementModel.fromJson(snapshot.data()!, docId: snapshot.id);
    }
    return null;
  }

  @override
  Future<void> closeMonthAndSnapshot({
    required String messId,
    required String yearMonth,
    required String closedByUserId,
    required String closedByUserName,
    required MessMonthlyCalculation calc,
  }) async {
    final memberSummaries = calc.memberSummaries.values
        .map((s) => MemberSettlementSummary(
              userId: s.userId,
              userName: s.userName,
              mealsEaten: s.mealsEaten,
              amountOwed: s.amountOwed,
              depositTotal: s.depositTotal,
              balance: s.balance,
            ))
        .toList();

    final model = SettlementModel(
      id: yearMonth,
      messId: messId,
      yearMonth: yearMonth,
      totalMeals: calc.totalMeals,
      totalBazarCost: calc.totalBazarCost,
      mealRate: calc.mealRate,
      closedByUserId: closedByUserId,
      closedByUserName: closedByUserName,
      closedAt: DateTime.now(),
      memberSummaries: memberSummaries,
    );

    await _firestoreService.setData(
      path: _documentPath(messId, yearMonth),
      data: model.toJson(),
    );
  }
}

import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/meal_selection_entity.dart';
import '../../domain/repositories/meal_repository.dart';
import '../models/meal_selection_model.dart';

class MealRepositoryImpl implements MealRepository {
  final FirestoreService _firestoreService;

  MealRepositoryImpl({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  String _collectionPath(String messId) => 'households/$messId/meals';
  String _documentPath(String messId, String dateStr, String userId) =>
      'households/$messId/meals/${dateStr}_$userId';

  @override
  Stream<List<MealSelectionEntity>> watchDailyMeals({
    required String messId,
    required String dateStr,
  }) {
    return _firestoreService
        .collectionStream(
          path: _collectionPath(messId),
          queryBuilder: (query) => query.where('date', isEqualTo: dateStr),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => MealSelectionModel.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  @override
  Stream<MealSelectionEntity?> watchUserDailyMeal({
    required String messId,
    required String userId,
    required String dateStr,
  }) {
    final path = _documentPath(messId, dateStr, userId);
    return _firestoreService.documentStream(path).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return MealSelectionModel.fromJson(snapshot.data()!, docId: snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<void> updateMealSelection({
    required String messId,
    required String userId,
    required String userName,
    required String dateStr,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    final path = _documentPath(messId, dateStr, userId);
    final model = MealSelectionModel(
      id: '${dateStr}_$userId',
      messId: messId,
      userId: userId,
      userName: userName,
      date: dateStr,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.setData(
      path: path,
      data: model.toJson(),
    );
  }
}

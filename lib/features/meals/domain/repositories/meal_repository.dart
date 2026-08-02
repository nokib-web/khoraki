import '../entities/meal_selection_entity.dart';

abstract class MealRepository {
  Stream<List<MealSelectionEntity>> watchDailyMeals({
    required String messId,
    required String dateStr,
  });

  Stream<MealSelectionEntity?> watchUserDailyMeal({
    required String messId,
    required String userId,
    required String dateStr,
  });

  Future<void> updateMealSelection({
    required String messId,
    required String userId,
    required String userName,
    required String dateStr,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  });
}

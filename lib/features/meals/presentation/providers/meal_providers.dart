import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/repositories/meal_repository_impl.dart';
import '../../domain/entities/meal_selection_entity.dart';
import '../../domain/repositories/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final mealDeadlineHourProvider = Provider<int>((ref) => 20); // 8:00 PM previous day

class UserMealParams {
  final String messId;
  final String userId;
  final DateTime date;

  const UserMealParams({
    required this.messId,
    required this.userId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMealParams &&
          runtimeType == other.runtimeType &&
          messId == other.messId &&
          userId == other.userId &&
          date == other.date;

  @override
  int get hashCode => messId.hashCode ^ userId.hashCode ^ date.hashCode;
}

class DailyMessMealParams {
  final String messId;
  final DateTime date;

  const DailyMessMealParams({
    required this.messId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyMessMealParams &&
          runtimeType == other.runtimeType &&
          messId == other.messId &&
          date == other.date;

  @override
  int get hashCode => messId.hashCode ^ date.hashCode;
}

final userDailyMealStreamProvider =
    StreamProvider.family<MealSelectionEntity?, UserMealParams>((ref, params) {
  final repository = ref.watch(mealRepositoryProvider);
  final dateStr = AppDateUtils.formatDate(params.date);
  return repository.watchUserDailyMeal(
    messId: params.messId,
    userId: params.userId,
    dateStr: dateStr,
  );
});

final dailyMessMealsStreamProvider =
    StreamProvider.family<List<MealSelectionEntity>, DailyMessMealParams>((ref, params) {
  final repository = ref.watch(mealRepositoryProvider);
  final dateStr = AppDateUtils.formatDate(params.date);
  return repository.watchDailyMeals(
    messId: params.messId,
    dateStr: dateStr,
  );
});

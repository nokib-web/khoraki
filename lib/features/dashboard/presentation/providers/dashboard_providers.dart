import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/meal_calculator.dart';
import '../../../bazar/data/models/bazar_entry_model.dart';
import '../../../bazar/domain/entities/bazar_entry_entity.dart';
import '../../../meals/data/models/meal_selection_model.dart';
import '../../../meals/domain/entities/meal_selection_entity.dart';

final allMonthlyMealsStreamProvider = StreamProvider.family<List<MealSelectionEntity>, String>((ref, messId) {
  final firestoreService = FirestoreService();
  final now = DateTime.now();
  final startOfMonth = AppDateUtils.formatDate(DateTime(now.year, now.month, 1));
  final endOfMonth = AppDateUtils.formatDate(DateTime(now.year, now.month + 1, 0));

  return firestoreService
      .collectionStream(
        path: 'households/$messId/meals',
        queryBuilder: (query) => query
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThanOrEqualTo: endOfMonth),
      )
      .map((snapshot) => snapshot.docs
          .map((doc) => MealSelectionModel.fromJson(doc.data(), docId: doc.id))
          .toList());
});

final allMonthlyBazarStreamProvider = StreamProvider.family<List<BazarEntryEntity>, String>((ref, messId) {
  final firestoreService = FirestoreService();
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

  return firestoreService
      .collectionStream(
        path: 'households/$messId/bazars',
        queryBuilder: (query) => query
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThanOrEqualTo: endOfMonth),
      )
      .map((snapshot) => snapshot.docs
          .map((doc) => BazarEntryModel.fromJson(doc.data(), docId: doc.id))
          .toList());
});

final monthlyCalculationProvider = Provider.family<AsyncValue<MessMonthlyCalculation>, String>((ref, messId) {
  final mealsAsync = ref.watch(allMonthlyMealsStreamProvider(messId));
  final bazarAsync = ref.watch(allMonthlyBazarStreamProvider(messId));

  if (mealsAsync.isLoading || bazarAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (mealsAsync.hasError) {
    return AsyncValue.error(mealsAsync.error!, mealsAsync.stackTrace!);
  }

  if (bazarAsync.hasError) {
    return AsyncValue.error(bazarAsync.error!, bazarAsync.stackTrace!);
  }

  final mealEntries = mealsAsync.value ?? [];
  final bazarEntries = bazarAsync.value ?? [];

  final calc = MealCalculator.calculateMonthlyMessStats(
    mealEntries: mealEntries,
    bazarEntries: bazarEntries,
  );

  return AsyncValue.data(calc);
});

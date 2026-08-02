import '../../features/bazar/domain/entities/bazar_entry_entity.dart';
import '../../features/meals/domain/entities/meal_selection_entity.dart';

class MemberMealSummary {
  final String userId;
  final String userName;
  final double mealsEaten;
  final double amountOwed;
  final double depositTotal;
  final double balance; // depositTotal - amountOwed

  const MemberMealSummary({
    required this.userId,
    required this.userName,
    required this.mealsEaten,
    required this.amountOwed,
    required this.depositTotal,
    required this.balance,
  });
}

class MessMonthlyCalculation {
  final double totalMeals;
  final double totalBazarCost;
  final double mealRate; // totalBazarCost / totalMeals (0.0 if totalMeals == 0)
  final Map<String, MemberMealSummary> memberSummaries;

  const MessMonthlyCalculation({
    required this.totalMeals,
    required this.totalBazarCost,
    required this.mealRate,
    required this.memberSummaries,
  });
}

class MealCalculator {
  MealCalculator._();

  /// Pure function calculating monthly mess metrics and member balances
  static MessMonthlyCalculation calculateMonthlyMessStats({
    required List<MealSelectionEntity> mealEntries,
    required List<BazarEntryEntity> bazarEntries,
    Map<String, double> memberDeposits = const {},
    Map<String, String> userNames = const {},
  }) {
    // 1. Calculate Total Meals
    double totalMeals = 0.0;
    final Map<String, double> memberMealCounts = {};
    final Map<String, String> resolvedNames = Map.from(userNames);

    for (final meal in mealEntries) {
      final count = meal.totalMeals;
      totalMeals += count;
      memberMealCounts[meal.userId] = (memberMealCounts[meal.userId] ?? 0.0) + count;
      if (meal.userName.isNotEmpty) {
        resolvedNames[meal.userId] = meal.userName;
      }
    }

    // 2. Calculate Total Bazar Cost
    double totalBazarCost = 0.0;
    for (final bazar in bazarEntries) {
      totalBazarCost += bazar.amount;
      if (bazar.createdByUserId.isNotEmpty && bazar.createdByUserName.isNotEmpty) {
        resolvedNames[bazar.createdByUserId] = bazar.createdByUserName;
      }
    }

    // 3. Calculate Meal Rate (safe division)
    final double mealRate = totalMeals > 0 ? (totalBazarCost / totalMeals) : 0.0;

    // 4. Collect all distinct user IDs
    final Set<String> allUserIds = {
      ...memberMealCounts.keys,
      ...memberDeposits.keys,
      ...resolvedNames.keys,
    };

    // 5. Calculate Member Summaries
    final Map<String, MemberMealSummary> memberSummaries = {};
    for (final userId in allUserIds) {
      final mealsEaten = memberMealCounts[userId] ?? 0.0;
      final amountOwed = mealsEaten * mealRate;
      final depositTotal = memberDeposits[userId] ?? 0.0;
      final balance = depositTotal - amountOwed;
      final userName = resolvedNames[userId] ?? 'Member ($userId)';

      memberSummaries[userId] = MemberMealSummary(
        userId: userId,
        userName: userName,
        mealsEaten: mealsEaten,
        amountOwed: amountOwed,
        depositTotal: depositTotal,
        balance: balance,
      );
    }

    return MessMonthlyCalculation(
      totalMeals: totalMeals,
      totalBazarCost: totalBazarCost,
      mealRate: mealRate,
      memberSummaries: memberSummaries,
    );
  }
}

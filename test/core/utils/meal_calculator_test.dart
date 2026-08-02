import 'package:flutter_test/flutter_test.dart';
import 'package:khoraki/core/utils/meal_calculator.dart';
import 'package:khoraki/features/bazar/domain/entities/bazar_entry_entity.dart';
import 'package:khoraki/features/meals/domain/entities/meal_selection_entity.dart';

void main() {
  group('MealCalculator Unit Tests', () {
    test('Normal case: calculates correct meal rate and member balances', () {
      final mealEntries = [
        const MealSelectionEntity(
          id: '1',
          messId: 'mess_1',
          userId: 'user_1',
          userName: 'Alice',
          date: '2026-08-01',
          breakfast: true,
          lunch: true,
          dinner: true, // 3 meals
        ),
        const MealSelectionEntity(
          id: '2',
          messId: 'mess_1',
          userId: 'user_2',
          userName: 'Bob',
          date: '2026-08-01',
          breakfast: false,
          lunch: true,
          dinner: true, // 2 meals
        ),
      ];

      final bazarEntries = [
        BazarEntryEntity(
          id: 'b1',
          messId: 'mess_1',
          createdByUserId: 'user_1',
          createdByUserName: 'Alice',
          amount: 500.0,
          date: DateTime(2026, 8, 1),
        ),
      ];

      final result = MealCalculator.calculateMonthlyMessStats(
        mealEntries: mealEntries,
        bazarEntries: bazarEntries,
        memberDeposits: {'user_1': 500.0, 'user_2': 0.0},
      );

      // Total meals: 3 + 2 = 5
      expect(result.totalMeals, equals(5.0));
      // Total bazar cost: 500
      expect(result.totalBazarCost, equals(500.0));
      // Meal rate: 500 / 5 = 100 per meal
      expect(result.mealRate, equals(100.0));

      // Alice (user_1): 3 meals * 100 = 300 owed. Deposit: 500. Balance: 200
      final alice = result.memberSummaries['user_1']!;
      expect(alice.mealsEaten, equals(3.0));
      expect(alice.amountOwed, equals(300.0));
      expect(alice.balance, equals(200.0));

      // Bob (user_2): 2 meals * 100 = 200 owed. Deposit: 0. Balance: -200
      final bob = result.memberSummaries['user_2']!;
      expect(bob.mealsEaten, equals(2.0));
      expect(bob.amountOwed, equals(200.0));
      expect(bob.balance, equals(-200.0));
    });

    test('Zero meals edge case: prevents divide by zero and returns 0.0 meal rate', () {
      final mealEntries = <MealSelectionEntity>[];
      final bazarEntries = [
        BazarEntryEntity(
          id: 'b1',
          messId: 'mess_1',
          createdByUserId: 'user_1',
          createdByUserName: 'Alice',
          amount: 1000.0,
          date: DateTime(2026, 8, 1),
        ),
      ];

      final result = MealCalculator.calculateMonthlyMessStats(
        mealEntries: mealEntries,
        bazarEntries: bazarEntries,
        userNames: {'user_1': 'Alice'},
      );

      expect(result.totalMeals, equals(0.0));
      expect(result.totalBazarCost, equals(1000.0));
      expect(result.mealRate, equals(0.0));
    });

    test('Mid-month joined member case: correctly accounts for partial month meals', () {
      final mealEntries = [
        // Old member
        const MealSelectionEntity(
          id: '1',
          messId: 'mess_1',
          userId: 'user_old',
          userName: 'Old Member',
          date: '2026-08-01',
          breakfast: true,
          lunch: true,
          dinner: true, // 3 meals
        ),
        // Mid-month joined member (joins on Aug 15)
        const MealSelectionEntity(
          id: '2',
          messId: 'mess_1',
          userId: 'user_new',
          userName: 'New Member',
          date: '2026-08-15',
          breakfast: false,
          lunch: true,
          dinner: true, // 2 meals
        ),
      ];

      final bazarEntries = [
        BazarEntryEntity(
          id: 'b1',
          messId: 'mess_1',
          createdByUserId: 'user_old',
          createdByUserName: 'Old Member',
          amount: 500.0,
          date: DateTime(2026, 8, 15),
        ),
      ];

      final result = MealCalculator.calculateMonthlyMessStats(
        mealEntries: mealEntries,
        bazarEntries: bazarEntries,
        memberDeposits: {'user_new': 200.0},
      );

      // Total meals = 3 + 2 = 5 meals
      // Meal rate = 500 / 5 = 100
      expect(result.mealRate, equals(100.0));

      final newMember = result.memberSummaries['user_new']!;
      expect(newMember.mealsEaten, equals(2.0));
      expect(newMember.amountOwed, equals(200.0)); // 2 * 100
      expect(newMember.depositTotal, equals(200.0));
      expect(newMember.balance, equals(0.0)); // 200 - 200 = 0
    });
  });
}

class MealDeadlineUtils {
  MealDeadlineUtils._();

  /// Returns true if the deadline for toggling meals on [mealDate] has passed.
  /// Rule: Deadline is [deadlineHour] (default 20 = 8 PM) of the PREVIOUS day relative to [mealDate].
  static bool isDeadlinePassed(DateTime mealDate, {int deadlineHour = 20, DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(mealDate.year, mealDate.month, mealDate.day);

    // If targetDate is in the past, deadline is definitely passed
    if (targetDate.isBefore(today)) {
      return true;
    }

    // Previous day relative to target meal date
    final previousDay = targetDate.subtract(const Duration(days: 1));
    final deadlineTime = DateTime(
      previousDay.year,
      previousDay.month,
      previousDay.day,
      deadlineHour,
      0,
    );

    return now.isAfter(deadlineTime);
  }
}

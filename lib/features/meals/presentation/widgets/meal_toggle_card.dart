import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/meal_deadline_utils.dart';
import '../../domain/entities/meal_selection_entity.dart';
import '../providers/meal_providers.dart';

class MealToggleCard extends ConsumerWidget {
  const MealToggleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final user = ref.watch(currentUserProvider);
    final deadlineHour = ref.watch(mealDeadlineHourProvider);

    if (user == null || user.messId == null) {
      return const SizedBox.shrink();
    }

    final isLocked = MealDeadlineUtils.isDeadlinePassed(
      selectedDate,
      deadlineHour: deadlineHour,
    );

    final userMealAsync = ref.watch(userDailyMealStreamProvider(
      UserMealParams(
        messId: user.messId!,
        userId: user.uid,
        date: selectedDate,
      ),
    ));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meal Selection (${AppDateUtils.formatDisplayDate(selectedDate)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isLocked)
                  const Chip(
                    avatar: Icon(Icons.lock, size: 16, color: Colors.white),
                    label: Text('Locked', style: TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: AppColors.error,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (isLocked) ...[
              const SizedBox(height: 8),
              Text(
                'Deadline for this date was 8:00 PM of the previous day.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error.withAlpha(200),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const Divider(height: 24),
            userMealAsync.when(
              data: (mealSelection) {
                final currentMeal = mealSelection ??
                    MealSelectionEntity(
                      id: '${AppDateUtils.formatDate(selectedDate)}_${user.uid}',
                      messId: user.messId!,
                      userId: user.uid,
                      userName: user.displayName ?? 'Member',
                      date: AppDateUtils.formatDate(selectedDate),
                    );

                return Column(
                  children: [
                    _buildToggleRow(
                      context: context,
                      ref: ref,
                      icon: Icons.free_breakfast,
                      title: 'Breakfast',
                      value: currentMeal.breakfast,
                      isLocked: isLocked,
                      onChanged: (val) {
                        _updateMeal(ref, user, selectedDate, currentMeal.copyWith(breakfast: val));
                      },
                    ),
                    const Divider(height: 16),
                    _buildToggleRow(
                      context: context,
                      ref: ref,
                      icon: Icons.lunch_dining,
                      title: 'Lunch',
                      value: currentMeal.lunch,
                      isLocked: isLocked,
                      onChanged: (val) {
                        _updateMeal(ref, user, selectedDate, currentMeal.copyWith(lunch: val));
                      },
                    ),
                    const Divider(height: 16),
                    _buildToggleRow(
                      context: context,
                      ref: ref,
                      icon: Icons.dinner_dining,
                      title: 'Dinner',
                      value: currentMeal.dinner,
                      isLocked: isLocked,
                      onChanged: (val) {
                        _updateMeal(ref, user, selectedDate, currentMeal.copyWith(dinner: val));
                      },
                    ),
                  ],
                );
              },
              loading: () => const LoadingIndicator(message: 'Loading meal choices...'),
              error: (err, stack) => Text('Error loading meal choices: $err'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateMeal(
    WidgetRef ref,
    dynamic user,
    DateTime selectedDate,
    MealSelectionEntity updatedMeal,
  ) {
    ref.read(mealRepositoryProvider).updateMealSelection(
          messId: user.messId!,
          userId: user.uid,
          userName: user.displayName ?? 'Member',
          dateStr: AppDateUtils.formatDate(selectedDate),
          breakfast: updatedMeal.breakfast,
          lunch: updatedMeal.lunch,
          dinner: updatedMeal.dinner,
        );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required bool value,
    required bool isLocked,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: isLocked ? null : onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}

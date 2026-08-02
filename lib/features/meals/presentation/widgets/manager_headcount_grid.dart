import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/meal_providers.dart';

class ManagerHeadcountGrid extends ConsumerWidget {
  const ManagerHeadcountGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Only visible for manager role
    if (role != 'manager' || user?.messId == null) {
      return const SizedBox.shrink();
    }

    final dailyMealsAsync = ref.watch(dailyMessMealsStreamProvider(
      DailyMessMealParams(
        messId: user!.messId!,
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
                const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Manager Headcount Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Realtime',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            dailyMealsAsync.when(
              data: (mealsList) {
                final totalBreakfast =
                    mealsList.where((m) => m.breakfast).length;
                final totalLunch = mealsList.where((m) => m.lunch).length;
                final totalDinner = mealsList.where((m) => m.dinner).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Summary Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryBadge('Breakfast', totalBreakfast, Icons.free_breakfast),
                        _buildSummaryBadge('Lunch', totalLunch, Icons.lunch_dining),
                        _buildSummaryBadge('Dinner', totalDinner, Icons.dinner_dining),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Member Meal List',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (mealsList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No meal entries recorded for this date yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Member')),
                            DataColumn(label: Text('B\'fast')),
                            DataColumn(label: Text('Lunch')),
                            DataColumn(label: Text('Dinner')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: mealsList.map((meal) {
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  meal.userName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                )),
                                DataCell(_buildStatusIcon(meal.breakfast)),
                                DataCell(_buildStatusIcon(meal.lunch)),
                                DataCell(_buildStatusIcon(meal.dinner)),
                                DataCell(Text(
                                  '${meal.totalMeals.toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LoadingIndicator(message: 'Updating headcount...'),
              error: (err, stack) => Text('Error loading headcount: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isActive) {
    return Icon(
      isActive ? Icons.check_circle : Icons.cancel,
      color: isActive ? AppColors.success : AppColors.textSecondary.withAlpha(80),
      size: 20,
    );
  }
}

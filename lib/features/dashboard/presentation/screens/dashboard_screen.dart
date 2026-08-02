import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../bazar/presentation/screens/bazar_list_screen.dart';
import '../../../meals/presentation/providers/meal_providers.dart';
import '../../../meals/presentation/screens/meals_screen.dart';
import '../../../notices/presentation/providers/notice_providers.dart';
import '../../../notices/presentation/screens/notices_list_screen.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 3; // Default to Dashboard Overview tab

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider);
    final messId = ref.watch(currentMessIdProvider);

    final unreadNoticeCount = ref.watch(unreadNoticeCountProvider);

    final screens = [
      const MealsScreen(),
      const BazarListScreen(),
      const NoticesListScreen(),
      _buildDashboardHomeTab(user, role, messId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Bazar',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadNoticeCount > 0,
              label: Text('$unreadNoticeCount'),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.campaign),
            ),
            label: 'Notices',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHomeTab(dynamic user, String? role, String? messId) {
    if (messId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: Text('Please join or create a mess first.')),
      );
    }

    final isManager = role == 'manager';

    // Watch today's headcount meals
    final today = DateTime.now();
    final todayMealsAsync = ref.watch(dailyMessMealsStreamProvider(
      DailyMessMealParams(messId: messId, date: today),
    ));

    // Watch monthly calculation stats
    final monthlyCalcAsync = ref.watch(monthlyCalculationProvider(messId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Settlements',
            onPressed: () {
              context.push('/settlements');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(monthlyCalculationProvider(messId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Role: ${role?.toUpperCase() ?? 'MEMBER'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            isManager ? 'Manager' : 'Member',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor: isManager ? AppColors.secondary : AppColors.primary,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Today's Meal Headcount Card
                Text(
                  'Today\'s Headcount (${AppDateUtils.formatDisplayDate(today)})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                todayMealsAsync.when(
                  data: (mealsList) {
                    final bCount = mealsList.where((m) => m.breakfast).length;
                    final lCount = mealsList.where((m) => m.lunch).length;
                    final dCount = mealsList.where((m) => m.dinner).length;

                    return Row(
                      children: [
                        Expanded(child: _buildHeadcountItem('Breakfast', bCount, Icons.free_breakfast)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildHeadcountItem('Lunch', lCount, Icons.lunch_dining)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildHeadcountItem('Dinner', dCount, Icons.dinner_dining)),
                      ],
                    );
                  },
                  loading: () => const LoadingIndicator(message: 'Loading today\'s count...'),
                  error: (err, stack) => Text('Error loading today\'s meals: $err'),
                ),
                const SizedBox(height: 24),

                // Monthly Financial Calculation Section
                monthlyCalcAsync.when(
                  data: (calc) {
                    final userSummary = user != null ? calc.memberSummaries[user.uid] : null;
                    final userBalance = userSummary?.balance ?? 0.0;
                    final isPositive = userBalance >= 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Total Bazar Cost & Meal Rate Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Monthly Bazar',
                                value: CurrencyUtils.formatBDT(calc.totalBazarCost),
                                subtitle: '${calc.totalMeals.toInt()} Total Meals',
                                icon: Icons.shopping_bag,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Meal Rate',
                                value: '৳${calc.mealRate.toStringAsFixed(2)}',
                                subtitle: 'Per Meal Cost',
                                icon: Icons.calculate,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // "Your Balance" Card
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: isPositive
                              ? AppColors.success.withAlpha(20)
                              : AppColors.error.withAlpha(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isPositive ? Icons.account_balance_wallet : Icons.warning_amber,
                                      color: isPositive ? AppColors.success : AppColors.error,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Your Balance Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Meals Eaten:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        Text(
                                          '${userSummary?.mealsEaten.toInt() ?? 0} Meals',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Amount Owed:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        Text(
                                          CurrencyUtils.formatBDT(userSummary?.amountOwed ?? 0.0),
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isPositive ? AppColors.success : AppColors.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isPositive ? 'Credit Balance (Owed to you):' : 'Due Amount (You owe):',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        CurrencyUtils.formatBDT(userBalance.abs()),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Manager Summary Table
                        if (isManager) ...[
                          const Row(
                            children: [
                              Icon(Icons.admin_panel_settings, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Manager Balance Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Member')),
                                  DataColumn(label: Text('Meals')),
                                  DataColumn(label: Text('Owed')),
                                  DataColumn(label: Text('Spent/Paid')),
                                  DataColumn(label: Text('Net Balance')),
                                ],
                                rows: calc.memberSummaries.values.map((member) {
                                  final isMemberPositive = member.balance >= 0;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(member.userName, style: const TextStyle(fontWeight: FontWeight.w500))),
                                      DataCell(Text('${member.mealsEaten.toInt()}')),
                                      DataCell(Text(CurrencyUtils.formatBDT(member.amountOwed))),
                                      DataCell(Text(CurrencyUtils.formatBDT(member.depositTotal))),
                                      DataCell(
                                        Text(
                                          '${isMemberPositive ? '+' : ''}${CurrencyUtils.formatBDT(member.balance)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isMemberPositive ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const LoadingIndicator(message: 'Calculating monthly stats...'),
                  error: (err, stack) => Text('Error calculating stats: $err'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadcountItem(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withAlpha(30),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

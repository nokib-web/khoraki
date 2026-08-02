import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/settlement_providers.dart';

class SettlementsListScreen extends ConsumerStatefulWidget {
  const SettlementsListScreen({super.key});

  @override
  ConsumerState<SettlementsListScreen> createState() => _SettlementsListScreenState();
}

class _SettlementsListScreenState extends ConsumerState<SettlementsListScreen> {
  bool _isClosingMonth = false;

  Future<void> _showCloseMonthDialog(BuildContext context, String messId, dynamic user) async {
    final now = DateTime.now();
    final yearMonth = AppDateUtils.formatDate(now, format: 'yyyy-MM');

    final calcAsync = ref.read(monthlyCalculationProvider(messId));

    if (!calcAsync.hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly data calculation is not ready.')),
      );
      return;
    }

    final calc = calcAsync.value!;

    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close Month ($yearMonth)?'),
        content: Text(
          'Are you sure you want to close and snapshot the final balances for $yearMonth?\n\n'
          'Total Bazar: ${CurrencyUtils.formatBDT(calc.totalBazarCost)}\n'
          'Total Meals: ${calc.totalMeals.toInt()}\n'
          'Meal Rate: ৳${calc.mealRate.toStringAsFixed(2)} / meal\n\n'
          'This historical snapshot will be saved permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm & Snapshot'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isClosingMonth = true);

    try {
      await ref.read(settlementRepositoryProvider).closeMonthAndSnapshot(
            messId: messId,
            yearMonth: yearMonth,
            closedByUserId: user.uid,
            closedByUserName: user.displayName ?? 'Manager',
            calc: calc,
          );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Month closed and snapshot created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to close month: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClosingMonth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider);

    if (user?.messId == null) {
      return const Scaffold(
        body: Center(child: Text('Please join a mess to view settlements.')),
      );
    }

    final isManager = role == 'manager';
    final settlementsAsync = ref.watch(messSettlementsStreamProvider(user!.messId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Settlements'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isManager) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Manager Settlement Control',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Closing the month snapshots final balances for history and WhatsApp sharing.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Close Current Month',
                          isLoading: _isClosingMonth,
                          onPressed: () => _showCloseMonthDialog(context, user.messId!, user),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const Text(
                'Past Closed Months',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: settlementsAsync.when(
                  data: (settlements) {
                    if (settlements.isEmpty) {
                      return const Center(
                        child: Text(
                          'No historical closed months found yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: settlements.length,
                      itemBuilder: (context, index) {
                        final item = settlements[index];
                        final closedDateFormatted =
                            DateFormat('dd MMM yyyy').format(item.closedAt);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withAlpha(20),
                              child: const Icon(Icons.history, color: AppColors.primary),
                            ),
                            title: Text(
                              'Settlement (${item.yearMonth})',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Rate: ৳${item.mealRate.toStringAsFixed(2)} | Closed on $closedDateFormatted',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              context.push('/settlement-detail', extra: item);
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingIndicator(message: 'Loading settlements...'),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

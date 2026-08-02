import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bazar_providers.dart';
import '../widgets/receipt_view_dialog.dart';

class BazarListScreen extends ConsumerWidget {
  const BazarListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(currentUserRoleProvider);
    final selectedMonthYear = ref.watch(selectedMonthYearProvider);

    if (user?.messId == null) {
      return const Scaffold(
        body: Center(child: Text('Please join a mess to view bazar entries.')),
      );
    }

    final isManager = role == 'manager';

    final bazarStreamAsync = ref.watch(monthlyBazarStreamProvider(
      MonthlyBazarParams(
        messId: user!.messId!,
        year: selectedMonthYear.year,
        month: selectedMonthYear.month,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar & Expense List'),
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/add-bazar');
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Entry', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Month Selector Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () {
                      final current = ref.read(selectedMonthYearProvider);
                      final prevMonth = current.month == 1 ? 12 : current.month - 1;
                      final prevYear = current.month == 1 ? current.year - 1 : current.year;
                      ref.read(selectedMonthYearProvider.notifier).state =
                          MonthYear(year: prevYear, month: prevMonth);
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(
                      DateTime(selectedMonthYear.year, selectedMonthYear.month),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () {
                      final current = ref.read(selectedMonthYearProvider);
                      final nextMonth = current.month == 12 ? 1 : current.month + 1;
                      final nextYear = current.month == 12 ? current.year + 1 : current.year;
                      ref.read(selectedMonthYearProvider.notifier).state =
                          MonthYear(year: nextYear, month: nextMonth);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Area
            Expanded(
              child: bazarStreamAsync.when(
                data: (entries) {
                  final totalAmount = entries.fold<double>(
                    0.0,
                    (sum, item) => sum + item.amount,
                  );

                  return Column(
                    children: [
                      // Total Amount Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Bazar Expense (This Month)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              CurrencyUtils.formatBDT(totalAmount),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entries.length} Entries Recorded',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Entry List
                      Expanded(
                        child: entries.isEmpty
                            ? const Center(
                                child: Text(
                                  'No bazar entries recorded for this month.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary.withAlpha(20),
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        CurrencyUtils.formatBDT(entry.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'Date: ${AppDateUtils.formatDisplayDate(entry.date)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          if (entry.note != null && entry.note!.isNotEmpty)
                                            Text(
                                              'Note: ${entry.note}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          Text(
                                            'Added by: ${entry.createdByUserName}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: entry.hasReceipt
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.receipt_long,
                                                color: AppColors.primary,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => ReceiptViewDialog(
                                                    imageUrl: entry.receiptUrl!,
                                                  ),
                                                );
                                              },
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingIndicator(message: 'Loading bazar list...'),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

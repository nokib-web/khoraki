import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/settlement_entity.dart';

class SettlementDetailScreen extends StatelessWidget {
  final SettlementEntity settlement;

  const SettlementDetailScreen({super.key, required this.settlement});

  void _shareAsText(BuildContext context) {
    final text = settlement.formatShareableText();
    Share.share(
      text,
      subject: 'Khoraki Mess Settlement (${settlement.yearMonth})',
    );
  }

  @override
  Widget build(BuildContext context) {
    final closedDateFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(settlement.closedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settlement (${settlement.yearMonth})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share as text',
            onPressed: () => _shareAsText(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'MONTHLY SETTLEMENT SUMMARY (${settlement.yearMonth})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat('Total Bazar', CurrencyUtils.formatBDT(settlement.totalBazarCost)),
                        _buildHeaderStat('Total Meals', '${settlement.totalMeals.toInt()}'),
                        _buildHeaderStat('Meal Rate', '৳${settlement.mealRate.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Closed by ${settlement.closedByUserName} on $closedDateFormatted',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Table Title & Share Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Member Settlement Table',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareAsText(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Member Table
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Member Name')),
                      DataColumn(label: Text('Meals Eaten')),
                      DataColumn(label: Text('Deposit Paid')),
                      DataColumn(label: Text('Amount Owed')),
                      DataColumn(label: Text('Final Balance')),
                    ],
                    rows: settlement.memberSummaries.map((member) {
                      final isPositive = member.balance >= 0;
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            member.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text('${member.mealsEaten.toInt()}')),
                          DataCell(Text(CurrencyUtils.formatBDT(member.depositTotal))),
                          DataCell(Text(CurrencyUtils.formatBDT(member.amountOwed))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPositive
                                    ? AppColors.success.withAlpha(20)
                                    : AppColors.error.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}${CurrencyUtils.formatBDT(member.balance)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

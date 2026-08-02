import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/date_strip_widget.dart';
import '../widgets/manager_headcount_grid.dart';
import '../widgets/meal_toggle_card.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Management'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              DateStripWidget(),
              SizedBox(height: 8),
              MealToggleCard(),
              ManagerHeadcountGrid(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

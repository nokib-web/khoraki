import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/create_or_join_mess_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/bazar/presentation/screens/add_bazar_entry_screen.dart';
import '../../features/bazar/presentation/screens/bazar_list_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/meals/presentation/screens/meals_screen.dart';
import '../../features/notices/presentation/screens/notices_list_screen.dart';
import '../../features/settlement/domain/entities/settlement_entity.dart';
import '../../features/settlement/presentation/screens/settlement_detail_screen.dart';
import '../../features/settlement/presentation/screens/settlements_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/phone',
  routes: [
    GoRoute(
      path: '/phone',
      builder: (BuildContext context, GoRouterState state) => const PhoneInputScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerifyScreen(
          verificationId: args['verificationId'] as String? ?? '',
          phoneNumber: args['phoneNumber'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/setup-mess',
      builder: (BuildContext context, GoRouterState state) => const CreateOrJoinMessScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/meals',
      builder: (BuildContext context, GoRouterState state) => const MealsScreen(),
    ),
    GoRoute(
      path: '/bazar',
      builder: (BuildContext context, GoRouterState state) => const BazarListScreen(),
    ),
    GoRoute(
      path: '/add-bazar',
      builder: (BuildContext context, GoRouterState state) => const AddBazarEntryScreen(),
    ),
    GoRoute(
      path: '/notices',
      builder: (BuildContext context, GoRouterState state) => const NoticesListScreen(),
    ),
    GoRoute(
      path: '/settlements',
      builder: (BuildContext context, GoRouterState state) => const SettlementsListScreen(),
    ),
    GoRoute(
      path: '/settlement-detail',
      builder: (BuildContext context, GoRouterState state) {
        final settlement = state.extra as SettlementEntity;
        return SettlementDetailScreen(settlement: settlement);
      },
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/create_or_join_mess_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/meals/presentation/screens/meals_screen.dart';

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
  ],
);

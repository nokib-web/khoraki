import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
  ],
);

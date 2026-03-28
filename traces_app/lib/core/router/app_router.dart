import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


// import '../../features/auth/presentation/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash',      builder: (_, __) => const Scaffold(body: Center(child: Text('Traces')))),
      GoRoute(path: '/login',       builder: (_, __) => const Scaffold(body: Center(child: Text('Login')))),
      GoRoute(path: '/register',    builder: (_, __) => const Scaffold(body: Center(child: Text('Register')))),
      GoRoute(path: '/home',        builder: (_, __) => const Scaffold(body: Center(child: Text('Home')))),
      GoRoute(path: '/trips',       builder: (_, __) => const Scaffold(body: Center(child: Text('Trips')))),
      GoRoute(path: '/trips/:id',   builder: (_, __) => const Scaffold(body: Center(child: Text('Trip Detail')))),
      GoRoute(path: '/destinations',builder: (_, __) => const Scaffold(body: Center(child: Text('Destinations')))),
      GoRoute(path: '/profile',     builder: (_, __) => const Scaffold(body: Center(child: Text('Profile')))),
      GoRoute(path: '/map',         builder: (_, __) => const Scaffold(body: Center(child: Text('Map')))),
    ],
  );
});

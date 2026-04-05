import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traces_app/core/theme/app_theme.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding.dart';
import '../../features/destinations/presentation/screens/home_screen.dart';
import '../../features/destinations/presentation/screens/saved_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/social/presentation/screens/social_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/media/presentation/screens/media_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/financial/presentation/screens/financial_screen.dart';
import '../../features/gamification/presentation/screens/gamification_screen.dart';
import '../../features/destinations/presentation/screens/placecard_screen.dart';
import '../../features/destinations/presentation/screens/destinations_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Aliases & root (many screens used these paths; they were not registered)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/auth',
      ),
      GoRoute(
        path: '/explore',
        redirect: (context, state) => '/destinations',
      ),
      GoRoute(
        path: '/saved',
        redirect: (context, state) => '/trips',
      ),
      GoRoute(
        path: '/trips/plan',
        redirect: (context, state) => '/trips',
      ),
   
  GoRoute(
      path: '/place/:id',  // :id is a path parameter
      name: 'placeDetails',
      builder: (context, state) {
        // Extract the id from path parameters
        final id = state.pathParameters['id'] ?? '';
        return PlaceDetailsScreen(placeId: id);
      },
    ),
    
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/destinations',
        name: 'destinations',
        builder: (_, __) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/trips',
        name: 'trips',
        builder: (_, __) => const SavedScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/social',
        name: 'social',
        builder: (_, __) => const SocialScreen(),
      ),
      GoRoute(
        path: '/reviews',
        name: 'reviews',
        builder: (_, __) => const ReviewsScreen(),
      ),
      GoRoute(
        path: '/media',
        name: 'media',
        builder: (_, __) => const MediaScreen(),
      ),
      GoRoute(
        path: '/messaging',
        name: 'messaging',
        builder: (_, __) => const MessagingScreen(),
      ),
      GoRoute(
        path: '/financial',
        name: 'financial',
        builder: (_, __) => const FinancialScreen(),
      ),
      GoRoute(
        path: '/gamification',
        name: 'gamification',
        builder: (_, __) => const GamificationScreen(),
      ),
    ],

    // No session / login gating — only steer first-time users through onboarding.
    redirect: (context, state) async {
      if (state.matchedLocation == '/splash') return null;

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      final location = state.matchedLocation;
      final isOnboardingRoute = location == '/onboarding';

      if (!hasSeenOnboarding && !isOnboardingRoute) {
        return '/onboarding';
      }
      return null;
    },
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

// Add this splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAppropriateScreen();
  }

  Future<void> _navigateToAppropriateScreen() async {
    // Wait a moment for everything to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // First launch: onboarding → (on complete) /auth. Later launches: land on home.
    if (!hasSeenOnboarding && mounted) {
      context.go('/onboarding');
    } else if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.compass_calibration_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
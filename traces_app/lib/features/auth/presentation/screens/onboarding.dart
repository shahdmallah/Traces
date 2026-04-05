import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class OnboardingData {
  final int id;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  OnboardingData({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentScreen = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _onboardingScreens = [
    OnboardingData(
      id: 1,
      icon: Icons.map_rounded,
      title: 'Discover Amazing Places',
      description: 'Explore curated destinations tailored to your preferences, mood, and budget',
      gradientColors: [const Color(0xFF5F7A61), const Color(0xFF6B8568)],
    ),
    OnboardingData(
      id: 2,
      icon: Icons.explore_rounded,
      title: 'Smart Trip Planning',
      description: 'Plan your perfect journey with intelligent recommendations and personalized itineraries',
      gradientColors: [const Color(0xFF6B8568), const Color(0xFF8B9D83)],
    ),
    OnboardingData(
      id: 3,
      icon: Icons.favorite_rounded,
      title: 'Travel Your Way',
      description: 'Filter by distance, budget, and mood to find destinations that match your travel style',
      gradientColors: [const Color(0xFF8B9D83), const Color(0xFF9FAE96)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

 Future<void> _markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenOnboarding', true);
}

void _handleNext() async {
  if (_currentScreen < _onboardingScreens.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    await _markOnboardingComplete();
    if (mounted) context.go('/auth');
  }
}

void _handleSkip() async {
  await _markOnboardingComplete();
  if (mounted) context.go('/auth');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Skip button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedForeground,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Page View - Fixed the itemBuilder syntax
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentScreen = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: _onboardingScreens.length,
            itemBuilder: (BuildContext context, int index) {
              final screen = _onboardingScreens[index];
              final isActive = _currentScreen == index;
              
              return _OnboardingPage(
                screen: screen,
                isActive: isActive,
                scaleAnimation: _scaleAnimation,
                fadeAnimation: _fadeAnimation,
              );
            },
          ),
          
          // Bottom section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingScreens.length, (index) {
                      final isSelected = index == _currentScreen;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isSelected ? 32 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.muted,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentScreen == _onboardingScreens.length - 1 
                                ? 'Get Started' 
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData screen;
  final bool isActive;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const _OnboardingPage({
    required this.screen,
    required this.isActive,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          if (isActive)
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                );
              },
              child: _buildIconWithGradient(),
            )
          else
            _buildIconWithGradient(),
          
          const SizedBox(height: 48),
          
          // Title
          if (isActive)
            AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - fadeAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                screen.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              screen.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 16),
          
          // Description
          if (isActive)
            AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - fadeAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                screen.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mutedForeground,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              screen.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildIconWithGradient() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          // Blur effect
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: screen.gradientColors,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: screen.gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: screen.gradientColors,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              screen.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
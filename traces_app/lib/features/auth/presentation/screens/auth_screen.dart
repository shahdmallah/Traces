import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.secondary.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Hero section
          Positioned.fill(
            top: 0,
            child: Image.network(
              'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1200',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Overlay - Fixed: Using Colors.black with opacity instead of undefined AppColors.overlayDark
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background.withValues(alpha: 0.95),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compass_calibration_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Traces',
                        style: TextStyle(
                          fontSize: screenHeight * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Preserve the Memory of Places',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w300,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Auth cards
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sign in card
                      _buildAuthCard(
                        context,
                        title: 'Welcome Back',
                        subtitle: 'Sign in to your account',
                        buttonLabel: 'Sign In',
                        onPressed: () {
                          context.push('/login');
                        },
                        icon: Icons.login_rounded,
                        semanticsLabel: 'Sign in to your existing Traces account',
                      ),
                      const SizedBox(height: 12.0),
                      // Sign up card
                      _buildAuthCard(
                        context,
                        title: 'New Here?',
                        subtitle: 'Create your account and start exploring',
                        buttonLabel: 'Sign Up',
                        onPressed: () {
                          context.push('/signup');
                        },
                        icon: Icons.person_add_rounded,
                        isPrimary: false,
                        semanticsLabel: 'Create a new Traces account',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8.0),

                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // Continue as guest
                  Semantics(
                    label: 'Continue as guest without signing in',
                    button: true,
                    enabled: true,
                    onTap: () {
                      context.go('/home');
                    },
                    child: TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildAuthCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
    required IconData icon,
    bool isPrimary = true,
    String? semanticsLabel,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Semantics(
      label: semanticsLabel ?? title,
      button: true,
      enabled: true,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Semantics(
              image: true,
              label: title,
              child: Icon(
                icon,
                size: 24.0,
                color: isPrimary ? AppColors.primary : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: screenHeight * 0.028,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: screenHeight * 0.014,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            isPrimary
                ? Semantics(
                    label: buttonLabel,
                    button: true,
                    enabled: true,
                    onTap: onPressed,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(Icons.arrow_forward, size: screenHeight * 0.02),
                      label: Text(
                        buttonLabel,
                        style: TextStyle(fontSize: screenHeight * 0.018),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                : Semantics(
                    label: buttonLabel,
                    button: true,
                    enabled: true,
                    onTap: onPressed,
                    child: OutlinedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(Icons.arrow_forward, size: screenHeight * 0.02),
                      label: Text(
                        buttonLabel,
                        style: TextStyle(fontSize: screenHeight * 0.018),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
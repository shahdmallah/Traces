import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Shared tab bar for main app: Home → Explore → Saved → Profile (same as [HomeScreen]).
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.activeIndex,
  });

  /// 0 = home, 1 = explore (/destinations), 2 = saved (/trips), 3 = profile
  final int activeIndex;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.explore_outlined,
    Icons.favorite_border_rounded,
    Icons.person_outline_rounded,
  ];

  static const List<String> _routes = [
    '/home',
    '/destinations',
    '/trips',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (i) {
              final selected = i == activeIndex;
              return GestureDetector(
                onTap: () => context.go(_routes[i]),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _icons[i],
                    color: selected
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                    size: 26,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

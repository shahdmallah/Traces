import 'package:flutter/material.dart';
import 'package:traces_app/core/theme/app_theme.dart';

/// Common header style for screens with gradient background
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color cardColor;
  final double expandedHeight;
  final bool floating;
  final bool pinned;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.backgroundColor,
    required this.cardColor,
    this.expandedHeight = 100,
    this.floating = true,
    this.pinned = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor = isDark
        ? AppColors.darkForeground.withValues(alpha: 0.7)
        : AppColors.mutedForeground;

    return SliverAppBar(
      floating: floating,
      pinned: pinned,
      backgroundColor: backgroundColor,
      elevation: 0,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cardColor, backgroundColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.heading1.copyWith(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

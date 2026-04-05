import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Constants for spacing and sizing
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class IconSize {
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

class ShadowStyle {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Earthy themed trip card with image and details
class TripCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String destination;
  final String? organizer;
  final String price;
  final double? rating;
  final int? reviewCount;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final double? matchPercentage;

  const TripCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.destination,
    this.organizer,
    required this.price,
    this.rating,
    this.reviewCount,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                    color: AppColors.secondary,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.mutedForeground,
                            size: IconSize.xl,
                          ),
                        )
                      : null,
                ),
                // Soft outdoors overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.accent.withValues(alpha: 0.12),
                          AppColors.secondary.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: Spacing.md,
                  right: Spacing.md,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: ShadowStyle.medium,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.destructive,
                        size: IconSize.md,
                      ),
                    ),
                  ),
                ),
                // Match percentage badge
                if (matchPercentage != null)
                  Positioned(
                    top: Spacing.md,
                    left: Spacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        border: Border.all(
                          color: AppColors.background.withValues(alpha: 0.65),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${matchPercentage?.toStringAsFixed(0)}% match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Destination
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: IconSize.sm,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          destination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (organizer != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      organizer!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.md),
                  // Rating and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: IconSize.sm,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              rating!.toString(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                            if (reviewCount != null)
                              Text(
                                ' ($reviewCount)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Earthy themed button with customizable style
class EarthyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize? size;

  const EarthyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: IconSize.sm),
                  const SizedBox(width: Spacing.sm),
                  Text(label),
                ],
              )
            : Text(label));

    final baseStyle = _getButtonStyle(context, variant, size);
    final finalStyle = style != null ? style!.merge(baseStyle) : baseStyle;

    return SizedBox(
      height: size?.height ?? 48,
      width: size?.width,
      child: variant == ButtonVariant.primary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: finalStyle,
              child: child,
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: finalStyle,
              child: child,
            ),
    );
  }

  ButtonStyle _getButtonStyle(
    BuildContext context,
    ButtonVariant variant,
    ButtonSize? size,
  ) {
    final padding = _getPadding(size);

    if (variant == ButtonVariant.primary) {
      return ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        elevation: 0,
      );
    } else {
      return OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );
    }
  }

  EdgeInsetsGeometry _getPadding(ButtonSize? size) {
    if (size == ButtonSize.small) {
      return const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm);
    } else if (size == ButtonSize.large) {
      return const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg);
    } else {
      return const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md);
    }
  }
}

enum ButtonVariant { primary, secondary }

class ButtonSize {
  final double height;
  final double? width;

  const ButtonSize({required this.height, this.width});

  static const small = ButtonSize(height: 36, width: 100);
  static const medium = ButtonSize(height: 48, width: 120);
  static const large = ButtonSize(height: 56, width: 160);
  static const fullWidth = ButtonSize(height: 56);
}

/// Earthy themed badge/chip
class EarthyBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;

  const EarthyBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? (filled ? Colors.white : bgColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: filled ? bgColor : Colors.transparent,
          border: !filled ? Border.all(color: bgColor) : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: IconSize.sm, color: txtColor),
              const SizedBox(width: Spacing.sm),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Earthy themed container with rounded corners and shadow
class EarthyContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const EarthyContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.backgroundColor,
    this.borderRadius = AppRadius.md,
    this.border,
    this.shadows,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? (backgroundColor ?? AppColors.secondary) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: shadows ?? ShadowStyle.small,
        ),
        child: child,
      ),
    );
  }
}

/// Loading indicator with earthy style
class EarthyLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const EarthyLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        strokeWidth: 2,
      ),
    );
  }
}

/// Divider with earthy styling
class EarthyDivider extends StatelessWidget {
  final Color? color;
  final double height;
  final double thickness;

  const EarthyDivider({
    super.key,
    this.color,
    this.height = 16,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color ?? AppColors.border,
      height: height,
      thickness: thickness,
    );
  }
}

/// Info message card with earthy styling
class EarthyInfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const EarthyInfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: IconSize.lg,
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
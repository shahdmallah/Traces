import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRemove(String id) {
    ref.read(savedIdsProvider.notifier).toggle(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Destination removed from saved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.read(savedIdsProvider.notifier).toggle(id),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleCardClick(String id) => context.push('/place/$id');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.background;

    final savedAsync = ref.watch(savedDestinationsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: savedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (savedDestinations) => Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(savedDestinations.length),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: savedDestinations.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: [
                              const SizedBox(height: 24),
                              ..._buildSavedList(savedDestinations),
                              const SizedBox(height: 24),
                              _buildQuickActions(savedDestinations),
                              const SizedBox(height: 80),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MainBottomNav(activeIndex: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1722228097356-bd0202d99367?w=800'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFB85C50).withValues(alpha: 0.75),
                const Color(0xFF5F7A61).withValues(alpha: 0.8),
                const Color(0xFF6B8568).withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0, 0.4, curve: Curves.easeOut),
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0, 0.4, curve: Curves.easeOut),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Saved Places',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count ${count == 1 ? 'destination' : 'destinations'} saved',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkForeground : AppColors.foreground;

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Places Yet',
              style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Start exploring and save your favorite destinations for later',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/destinations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Text(
                'Explore Destinations',
                style: AppTextStyles.button.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSavedList(List<Destination> destinations) {
    return [
      for (int i = 0; i < destinations.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animationController,
                curve:
                    Interval(0.2 + (i * 0.05), 0.6, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                      0.2 + (i * 0.05), 0.6,
                      curve: Curves.easeOut),
                ),
              ),
              child: _buildDestinationCard(destinations[i]),
            ),
          ),
        ),
    ];
  }

  Widget _buildDestinationCard(Destination destination) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor =
        isDark ? AppColors.darkForeground : AppColors.foreground;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _handleCardClick(destination.id),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24)),
                      child: Image.network(
                        destination.image,
                        height: 224,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 224,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.image_not_supported,
                              size: 48, color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.w600, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(
                            destination.location,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                      if (destination.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          destination.description,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedForeground, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildTag(destination.budget, textColor),
                              if (destination.distanceLabel.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _buildTag(
                                    destination.distanceLabel, textColor),
                              ],
                            ],
                          ),
                          if (destination.savedDate != null)
                            Text(
                              'Saved ${destination.savedDate}',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => _handleRemove(destination.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.destructive),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall
            .copyWith(fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }

  Widget _buildQuickActions(List<Destination> savedDestinations) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/destinations'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                    side: BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded,
                          size: 20, color: AppColors.foreground),
                      const SizedBox(width: 8),
                      Text('Find More',
                          style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showPlanTripDialog(savedDestinations),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.airplanemode_active_rounded,
                          size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Plan Trip',
                          style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanTripDialog(List<Destination> savedDestinations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkForeground : AppColors.foreground;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Plan Your Trip',
            style: AppTextStyles.heading3
                .copyWith(fontWeight: FontWeight.w600, color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Would you like to create a trip with your saved places?',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '${savedDestinations.length} places selected',
                    style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    savedDestinations.map((d) => d.name).take(3).join(', '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mutedForeground),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Planning your trip...'),
                  duration: Duration(seconds: 2),
                ),
              );
              context.go('/trips/plan');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Planning'),
          ),
        ],
      ),
    );
  }
}

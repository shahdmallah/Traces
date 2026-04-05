import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  final String placeId;
  final String? placeName;

  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
    this.placeName,
  });

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen>
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

  @override
  Widget build(BuildContext context) {
    final destinationAsync = ref.watch(destinationByIdProvider(widget.placeId));
    // Saved state — watch optimistic notifier
    final savedIds = ref.watch(savedIdsProvider);
    final isSaved = savedIds.valueOrNull?.contains(widget.placeId) ?? false;

    return destinationAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error loading place: $err')),
      ),
      data: (destination) => _buildScaffold(context, destination, isSaved),
    );
  }

  Widget _buildScaffold(
      BuildContext context, Destination destination, bool isSaved) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _buildHeroImage(destination, isSaved)),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickInfo(destination),
                    const SizedBox(height: 24),
                    _buildTags(destination),
                    const SizedBox(height: 24),
                    _buildDescription(destination),
                    const SizedBox(height: 24),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCTA(isSaved),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Destination destination, bool isSaved) {
    return Stack(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Image.network(
            destination.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primary.withValues(alpha: 0.2),
              child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48)),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.foreground.withValues(alpha: 0.3),
                  AppColors.foreground.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        onTap: () => ref
                            .read(savedIdsProvider.notifier)
                            .toggle(destination.id),
                        color: isSaved ? AppColors.destructive : null,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share clicked')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _getOpacityAnimation(0, 0.4),
                        child: SlideTransition(
                          position: _getSlideUpAnimation(0, 0.4),
                          child: Text(
                            destination.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _getOpacityAnimation(0.1, 0.5),
                        child: SlideTransition(
                          position: _getSlideUpAnimation(0.1, 0.5),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 20, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                destination.location,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FadeTransition(
                  opacity: _getOpacityAnimation(0.2, 0.6),
                  child: ScaleTransition(
                    scale: _getScaleAnimation(0.2, 0.6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 20, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
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
        child: Icon(icon, size: 22, color: color ?? AppColors.foreground),
      ),
    );
  }

  Widget _buildQuickInfo(Destination destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _getOpacityAnimation(0.3, 0.7),
        child: SlideTransition(
          position: _getSlideUpAnimation(0.3, 0.7),
          child: Row(
            children: [
              _buildInfoCard(label: 'Budget', value: destination.budget),
              const SizedBox(width: 12),
              _buildInfoCard(
                  label: 'Distance',
                  value: destination.distanceLabel.isNotEmpty
                      ? destination.distanceLabel
                      : '${destination.distance} km'),
              const SizedBox(width: 12),
              _buildInfoCard(
                  label: 'Reviews',
                  value: destination.reviews.toLocaleString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.mutedForeground)),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(Destination destination) {
    if (destination.tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _getOpacityAnimation(0.4, 0.8),
        child: SlideTransition(
          position: _getSlideUpAnimation(0.4, 0.8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: destination.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(Destination destination) {
    if (destination.description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _getOpacityAnimation(0.5, 0.9),
        child: SlideTransition(
          position: _getSlideUpAnimation(0.5, 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About',
                  style: AppTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                destination.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    final infoItems = [
      {
        'icon': Icons.navigation_rounded,
        'title': 'Getting There',
        'description':
            'Easy access by car or public transport from major cities',
      },
      {
        'icon': Icons.access_time_rounded,
        'title': 'Best Time to Visit',
        'description':
            'Spring (March–May) and Fall (September–November) for ideal weather',
      },
      {
        'icon': Icons.info_rounded,
        'title': 'Good to Know',
        'description':
            'Suitable for all experience levels, guided tours available',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (int i = 0; i < infoItems.length; i++)
            FadeTransition(
              opacity: _getOpacityAnimation(0.6 + (i * 0.1), 1.0),
              child: SlideTransition(
                position: _getSlideUpAnimation(0.6 + (i * 0.1), 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          infoItems[i]['icon'] as IconData,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              infoItems[i]['title'] as String,
                              style: AppTextStyles.labelMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              infoItems[i]['description'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(bool isSaved) {
    return FadeTransition(
      opacity: _getOpacityAnimation(0.7, 1.0),
      child: SlideTransition(
        position: _getSlideUpAnimation(0.7, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.98),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(savedIdsProvider.notifier)
                          .toggle(widget.placeId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isSaved
                              ? 'Removed from favourites'
                              : 'Saved to favourites'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSaved
                            ? AppColors.destructive
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSaved
                              ? AppColors.destructive
                              : AppColors.border,
                        ),
                        boxShadow: [
                          if (!isSaved)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 26,
                        color: isSaved ? Colors.white : AppColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Planning trip...')),
                      ),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.primary, Color(0xFF6B8568)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 22, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Plan Trip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Animation helpers ──────────────────────────────────────────────────────

  Animation<double> _getOpacityAnimation(double start, double end) {
    return CurvedAnimation(
      parent: _animationController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _getSlideUpAnimation(double start, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<double> _getScaleAnimation(double start, double end) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }
}

// ─── Extension ────────────────────────────────────────────────────────────────

extension NumberFormatting on int {
  String toLocaleString() {
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

final List<String> budgetOptions = ['Budget', 'Mid', 'Premium', 'Luxury'];
final List<String> distanceOptions = ['< 2 km', '< 5 km', '< 10 km', '< 20 km'];

enum ViewMode { grid, list }
enum SortBy { rating, reviews }

// ─── Screen ───────────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  ViewMode _viewMode = ViewMode.grid;
  bool _showFilters = false;
  String? _selectedBudget;
  String? _selectedDistance;
  SortBy _sortBy = SortBy.rating;

  List<Destination> _applyFilters(List<Destination> source) {
    var filtered = List<Destination>.from(source);
    if (_selectedBudget != null) {
      filtered = filtered
          .where((d) => d.budget.toLowerCase() == _selectedBudget!.toLowerCase())
          .toList();
    }
    if (_selectedDistance != null) {
      final maxKm = double.parse(_selectedDistance!.split(' ')[1]);
      filtered = filtered.where((d) => d.distance <= maxKm).toList();
    }
    if (_sortBy == SortBy.rating) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      filtered.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return filtered;
  }

  void _handleCardTap(String id) => context.go('/place/$id');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor = isDark
        ? AppColors.darkForeground.withValues(alpha: 0.7)
        : AppColors.mutedForeground;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final destinationsAsync = ref.watch(destinationsProvider);

    // ── The correct Flutter pattern for "header + collapsible panel + scrollable
    // content + bottom nav" is:
    //
    //   Scaffold
    //     body: SafeArea
    //       Column
    //         [fixed header]
    //         [ClipRect collapsible panel — zero height when hidden]
    //         Expanded → [scrollable content]
    //     bottomNavigationBar: MainBottomNav   ← Scaffold owns this slot
    //
    // Scaffold automatically sizes `body` to exclude the bottomNavigationBar,
    // so the Column children always sum to exactly the available body height.
    // No manual arithmetic, no overflow.

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      // ── Hand the bottom nav to Scaffold — it reserves the right amount of
      // space automatically and handles safe-area insets on all devices.
      bottomNavigationBar: const MainBottomNav(activeIndex: 1),
      body: SafeArea(
        // SafeArea handles top (notch/status bar) and side insets.
        // Bottom is handled by Scaffold via bottomNavigationBar.
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────────────────────
            _ExploreHeader(
              viewMode: _viewMode,
              showFilters: _showFilters,
              textColor: textColor,
              mutedColor: mutedColor,
              screenWidth: screenWidth,
              destinationCount: destinationsAsync.maybeWhen(
                data: (d) => _applyFilters(d).length,
                orElse: () => null,
              ),
              onToggleView: () => setState(() {
                _viewMode =
                    _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
              }),
              onToggleFilters: () =>
                  setState(() => _showFilters = !_showFilters),
            ),

            // ── Filters panel ────────────────────────────────────────────────
            // ClipRect is the key: it hard-clips the child to its own box, so
            // when height animates to 0 the content becomes invisible instead
            // of painting over sibling widgets.
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                // heightFactor 0 → collapses to zero height, 1 → full height.
                // Because ClipRect clips to the AnimatedAlign's own bounds,
                // the content is fully hidden at heightFactor == 0.
                heightFactor: _showFilters ? 1.0 : 0.0,
                child: _FiltersPanel(
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  screenWidth: screenWidth,
                  selectedBudget: _selectedBudget,
                  selectedDistance: _selectedDistance,
                  sortBy: _sortBy,
                  onBudgetSelected: (b) =>
                      setState(() => _selectedBudget = b),
                  onDistanceSelected: (d) =>
                      setState(() => _selectedDistance = d),
                  onSortChanged: (s) => setState(() => _sortBy = s),
                ),
              ),
            ),

            // ── Content — Expanded takes all remaining space ─────────────────
            Expanded(
              child: destinationsAsync.when(
                data: (destinations) {
                  final filtered = _applyFilters(destinations);
                  return _viewMode == ViewMode.grid
                      ? _buildGridView(filtered, screenWidth, screenHeight)
                      : _buildListView(filtered, screenWidth, screenHeight);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child:
                      Text('Error: $err', style: TextStyle(color: textColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<Destination> destinations, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.06),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: sw > 600 ? 3 : 2,
          crossAxisSpacing: sw * 0.04,
          mainAxisSpacing: sw * 0.04,
          childAspectRatio: 0.65,
        ),
        itemCount: destinations.length,
        itemBuilder: (context, i) => Animate(
          effects: const [FadeEffect(), ScaleEffect()],
          delay: Duration(milliseconds: i * 50),
          child: _DestinationGridCard(
            destination: destinations[i],
            onTap: () => _handleCardTap(destinations[i].id),
            screenWidth: sw,
            screenHeight: sh,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
      List<Destination> destinations, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.06),
      child: ListView.builder(
        itemCount: destinations.length,
        itemBuilder: (context, i) => Animate(
          effects: const [FadeEffect(), MoveEffect(begin: Offset(-20, 0))],
          delay: Duration(milliseconds: i * 50),
          child: Padding(
            padding: EdgeInsets.only(bottom: sh * 0.02),
            child: _DestinationListCard(
              destination: destinations[i],
              onTap: () => _handleCardTap(destinations[i].id),
              screenWidth: sw,
              screenHeight: sh,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ExploreHeader extends StatelessWidget {
  final ViewMode viewMode;
  final bool showFilters;
  final Color textColor;
  final Color mutedColor;
  final double screenWidth;
  final int? destinationCount;
  final VoidCallback onToggleView;
  final VoidCallback onToggleFilters;

  const _ExploreHeader({
    required this.viewMode,
    required this.showFilters,
    required this.textColor,
    required this.mutedColor,
    required this.screenWidth,
    required this.destinationCount,
    required this.onToggleView,
    required this.onToggleFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFAF8F5)],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore',
                  style: AppTextStyles.heading1.copyWith(
                    color: textColor,
                    fontSize: screenWidth * 0.075,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                Text(
                  destinationCount != null
                      ? '$destinationCount destinations found'
                      : 'Loading…',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w300,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: viewMode == ViewMode.grid
                ? Icons.list_rounded
                : Icons.grid_view_rounded,
            color: textColor,
            active: false,
            onTap: onToggleView,
          ),
          SizedBox(width: screenWidth * 0.02),
          _HeaderIconButton(
            icon: Icons.tune_rounded,
            color: showFilters ? Colors.white : textColor,
            active: showFilters,
            onTap: onToggleFilters,
          ),
        ],
      ),
    );
  }
}

// ─── Filters panel ────────────────────────────────────────────────────────────

class _FiltersPanel extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final double screenWidth;
  final String? selectedBudget;
  final String? selectedDistance;
  final SortBy sortBy;
  final ValueChanged<String?> onBudgetSelected;
  final ValueChanged<String?> onDistanceSelected;
  final ValueChanged<SortBy> onSortChanged;

  const _FiltersPanel({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.screenWidth,
    required this.selectedBudget,
    required this.selectedDistance,
    required this.sortBy,
    required this.onBudgetSelected,
    required this.onDistanceSelected,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          screenWidth * 0.05, 12, screenWidth * 0.05, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filters',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: screenWidth * 0.042,
            ),
          ),
          const SizedBox(height: 10),
          _FilterLabel(label: 'Budget', mutedColor: mutedColor, screenWidth: screenWidth),
          const SizedBox(height: 6),
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: 6,
            children: budgetOptions.map((b) {
              final sel = selectedBudget == b;
              return _StyledChip(
                label: b,
                isSelected: sel,
                screenWidth: screenWidth,
                textColor: textColor,
                onTap: () => onBudgetSelected(sel ? null : b),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _FilterLabel(label: 'Distance', mutedColor: mutedColor, screenWidth: screenWidth),
          const SizedBox(height: 6),
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: 6,
            children: distanceOptions.map((d) {
              final sel = selectedDistance == d;
              return _StyledChip(
                label: d,
                isSelected: sel,
                screenWidth: screenWidth,
                textColor: textColor,
                onTap: () => onDistanceSelected(sel ? null : d),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _FilterLabel(label: 'Sort By', mutedColor: mutedColor, screenWidth: screenWidth),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SortButton(
                  title: 'Top Rated',
                  isSelected: sortBy == SortBy.rating,
                  screenWidth: screenWidth,
                  onTap: () => onSortChanged(SortBy.rating),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: _SortButton(
                  title: 'Most Reviewed',
                  isSelected: sortBy == SortBy.reviews,
                  screenWidth: screenWidth,
                  onTap: () => onSortChanged(SortBy.reviews),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String label;
  final Color mutedColor;
  final double screenWidth;

  const _FilterLabel({
    required this.label,
    required this.mutedColor,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        color: mutedColor,
        fontWeight: FontWeight.w500,
        fontSize: screenWidth * 0.032,
      ),
    );
  }
}

class _StyledChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final double screenWidth;
  final Color textColor;
  final VoidCallback onTap;

  const _StyledChip({
    required this.label,
    required this.isSelected,
    required this.screenWidth,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.032,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final double screenWidth;
  final VoidCallback onTap;

  const _SortButton({
    required this.title,
    required this.isSelected,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.022),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.foreground,
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Grid card ────────────────────────────────────────────────────────────────

class _DestinationGridCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const _DestinationGridCard({
    required this.destination,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor = isDark ? AppColors.darkForeground : AppColors.foreground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: screenWidth * 0.03,
              offset: Offset(0, screenHeight * 0.005),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.04)),
                  child: SizedBox(
                    height: screenHeight * 0.18,
                    width: double.infinity,
                    child: Image.network(
                      destination.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(Icons.image_not_supported, size: 32),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: screenWidth * 0.02,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: screenWidth * 0.03, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          destination.rating.toString(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
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
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: screenWidth * 0.035,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: screenWidth * 0.03,
                          color: AppColors.mutedForeground),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                            fontSize: screenWidth * 0.028,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      destination.budget,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

// ─── List card ────────────────────────────────────────────────────────────────

class _DestinationListCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const _DestinationListCard({
    required this.destination,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor = isDark ? AppColors.darkForeground : AppColors.foreground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: screenWidth * 0.03,
              offset: Offset(0, screenHeight * 0.005),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(screenWidth * 0.04)),
              child: SizedBox(
                width: screenWidth * 0.25,
                height: screenHeight * 0.12,
                child: Image.network(
                  destination.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.image_not_supported, size: 32),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: screenWidth * 0.04,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: screenWidth * 0.03,
                            color: AppColors.mutedForeground),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                              fontSize: screenWidth * 0.03,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: screenWidth * 0.035, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          destination.rating.toString(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            destination.budget,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
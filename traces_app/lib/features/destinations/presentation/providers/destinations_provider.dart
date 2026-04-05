import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/destinations_datasources.dart';
import '../../data/repositories/destinations_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/i_destinations_repository.dart';
import '../../domain/usecases/destinations_usecases.dart';

// =============================================================================
// Infrastructure providers — swap implementations here to target real APIs
// =============================================================================

/// Override this in tests / flavours to inject a different datasource.
final destinationsRemoteDataSourceProvider =
    Provider<IDestinationsRemoteDataSource>(
  (_) => DestinationsMockRemoteDataSource(),
  // For production:
  //   (_) => DestinationsSupabaseRemoteDataSource(supabase: Supabase.instance.client),
);

final destinationsLocalDataSourceProvider =
    Provider<IDestinationsLocalDataSource>(
  (_) => DestinationsInMemoryLocalDataSource(),
  // For production:
  //   (ref) => DestinationsHiveLocalDataSource(),
);

// =============================================================================
// Repository provider
// =============================================================================

final destinationsRepositoryProvider = Provider<IDestinationsRepository>((ref) {
  return DestinationsRepository(
    remote: ref.watch(destinationsRemoteDataSourceProvider),
    local: ref.watch(destinationsLocalDataSourceProvider),
  );
});

// =============================================================================
// Use-case providers
// =============================================================================

final getDestinationsUseCaseProvider = Provider((ref) {
  return GetDestinations(ref.watch(destinationsRepositoryProvider));
});

final getDestinationByIdUseCaseProvider = Provider((ref) {
  return GetDestinationById(ref.watch(destinationsRepositoryProvider));
});

final searchDestinationsUseCaseProvider = Provider((ref) {
  return SearchDestinations(ref.watch(destinationsRepositoryProvider));
});

final filterDestinationsUseCaseProvider = Provider((ref) {
  return FilterDestinations(ref.watch(destinationsRepositoryProvider));
});

final getSavedDestinationsUseCaseProvider = Provider((ref) {
  return GetSavedDestinations(ref.watch(destinationsRepositoryProvider));
});

final toggleSaveDestinationUseCaseProvider = Provider((ref) {
  return ToggleSaveDestination(ref.watch(destinationsRepositoryProvider));
});

// =============================================================================
// Data providers — consumed directly by screens
// =============================================================================

/// All destinations (Explore screen)
final destinationsProvider = FutureProvider<List<Destination>>((ref) {
  return ref.watch(getDestinationsUseCaseProvider).call();
});

/// Single destination detail (PlaceCard screen)
final destinationByIdProvider =
    FutureProvider.family<Destination, String>((ref, id) {
  return ref.watch(getDestinationByIdUseCaseProvider).call(id);
});

/// Search results
final searchDestinationsProvider =
    FutureProvider.family<List<Destination>, String>((ref, query) {
  return ref.watch(searchDestinationsUseCaseProvider).call(query);
});

/// Filtered results
typedef FilterParams = ({
  String? budget,
  double? minRating,
  List<String>? tags,
});

final filterDestinationsProvider =
    FutureProvider.family<List<Destination>, FilterParams>((ref, params) {
  return ref.watch(filterDestinationsUseCaseProvider).call(
        budget: params.budget,
        minRating: params.minRating,
        tags: params.tags,
      );
});

/// Saved / favourited destinations (Saved screen)
final savedDestinationsProvider = FutureProvider<List<Destination>>((ref) {
  return ref.watch(getSavedDestinationsUseCaseProvider).call();
});

/// Is a specific destination saved? (PlaceCard heart button)
final isDestinationSavedProvider =
    FutureProvider.family<bool, String>((ref, id) {
  return ref
      .watch(destinationsRepositoryProvider)
      .isDestinationSaved(id);
});

// =============================================================================
// Saved-state notifier — manages optimistic UI for save / unsave
// =============================================================================

class SavedIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final repo = ref.watch(destinationsRepositoryProvider);
    final ids = await repo.getSavedDestinations();
    return ids.map((d) => d.id).toSet();
  }

  Future<void> toggle(String id) async {
    final toggle = ref.read(toggleSaveDestinationUseCaseProvider);
    final nowSaved = await toggle.call(id);
    state = AsyncData(
      nowSaved
          ? {...?state.valueOrNull, id}
          : {...?state.valueOrNull}..remove(id),
    );
    // Invalidate so the saved list refreshes on next watch
    ref.invalidate(savedDestinationsProvider);
  }
}

final savedIdsProvider =
    AsyncNotifierProvider<SavedIdsNotifier, Set<String>>(SavedIdsNotifier.new);

// =============================================================================
// Home screen providers
// =============================================================================

final getCategoriesUseCaseProvider = Provider((ref) {
  return GetCategories(ref.watch(destinationsRepositoryProvider));
});

final getDestinationsByMoodUseCaseProvider = Provider((ref) {
  return GetDestinationsByMood(ref.watch(destinationsRepositoryProvider));
});

final getFeaturedDestinationsUseCaseProvider = Provider((ref) {
  return GetFeaturedDestinations(ref.watch(destinationsRepositoryProvider));
});

/// Travel mood categories
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(getCategoriesUseCaseProvider).call();
});

/// Featured / popular destinations for home feed
final featuredDestinationsProvider =
    FutureProvider.family<List<Destination>, int>((ref, limit) {
  return ref.watch(getFeaturedDestinationsUseCaseProvider).call(limit: limit);
});

/// Destinations filtered by mood (null = all)
final destinationsByMoodProvider =
    FutureProvider.family<List<Destination>, String?>((ref, mood) {
  if (mood == null || mood.isEmpty) {
    return ref.watch(getFeaturedDestinationsUseCaseProvider).call(limit: 5);
  }
  return ref.watch(getDestinationsByMoodUseCaseProvider).call(mood);
});

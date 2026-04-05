import '../../domain/entities/category.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/i_destinations_repository.dart';
import '../datasources/destinations_datasources.dart';

/// Concrete repository. Injected at app startup.
/// To switch to a real API: pass a [DestinationsSupabaseRemoteDataSource]
/// (or any other implementation) instead of the mock.
class DestinationsRepository implements IDestinationsRepository {
  DestinationsRepository({
    IDestinationsRemoteDataSource? remote,
    IDestinationsLocalDataSource? local,
  })  : _remote = remote ?? DestinationsMockRemoteDataSource(),
        _local = local ?? DestinationsInMemoryLocalDataSource();

  final IDestinationsRemoteDataSource _remote;
  final IDestinationsLocalDataSource _local;

  // -------------------------------------------------------------------------
  // Remote
  // -------------------------------------------------------------------------

  @override
  Future<List<Destination>> getDestinations() async {
    try {
      return await _remote.getDestinations();
    } catch (e) {
      throw Exception('Failed to fetch destinations: $e');
    }
  }

  @override
  Future<Destination> getDestinationById(String id) async {
    if (id.isEmpty) throw ArgumentError('Destination id must not be empty');
    try {
      return await _remote.getDestinationById(id);
    } catch (e) {
      throw Exception('Failed to fetch destination ($id): $e');
    }
  }

  @override
  Future<List<Destination>> searchDestinations(String query) async {
    try {
      return await _remote.searchDestinations(query);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  @override
  Future<List<Destination>> filterDestinations({
    String? budget,
    double? minRating,
    List<String>? tags,
  }) async {
    try {
      return await _remote.filterDestinations(
        budget: budget,
        minRating: minRating,
        tags: tags,
      );
    } catch (e) {
      throw Exception('Filter failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Local (saved / favourites)
  // -------------------------------------------------------------------------

  @override
  Future<List<Destination>> getSavedDestinations() async {
    final ids = await _local.getSavedIds();
    final all = await getDestinations();
    return all.where((d) => ids.contains(d.id)).toList();
  }

  @override
  Future<void> saveDestination(String id) => _local.saveDestination(id);

  @override
  Future<void> unsaveDestination(String id) => _local.unsaveDestination(id);

  @override
  Future<bool> isDestinationSaved(String id) =>
      _local.isDestinationSaved(id);

  // ── Categories ────────────────────────────────────────────────────────────

  @override
  Future<List<Category>> getCategories() async {
    try {
      return await _remote.getCategories();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<Destination>> getDestinationsByMood(String mood) async {
    try {
      return await _remote.getDestinationsByMood(mood);
    } catch (e) {
      throw Exception('Failed to fetch destinations by mood: $e');
    }
  }

  @override
  Future<List<Destination>> getFeaturedDestinations({int limit = 5}) async {
    try {
      return await _remote.getFeaturedDestinations(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch featured destinations: $e');
    }
  }
}

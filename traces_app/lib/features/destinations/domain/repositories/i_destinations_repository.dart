import '../entities/category.dart';
import '../entities/destination.dart';

/// Abstract contract that all data implementations must fulfil.
/// Screens / providers depend on this — never on concrete datasources.
abstract class IDestinationsRepository {
  /// Fetch all destinations.
  Future<List<Destination>> getDestinations();

  /// Fetch a single destination by [id]. Throws if not found.
  Future<Destination> getDestinationById(String id);

  /// Full-text search across name / location / tags.
  Future<List<Destination>> searchDestinations(String query);

  /// Filter by optional criteria.
  Future<List<Destination>> filterDestinations({
    String? budget,
    double? minRating,
    List<String>? tags,
  });

  /// Return destinations that the user has saved / favourited.
  Future<List<Destination>> getSavedDestinations();

  /// Persist a saved destination.
  Future<void> saveDestination(String id);

  /// Remove a saved destination.
  Future<void> unsaveDestination(String id);

  /// Returns true if [id] is in the saved list.
  Future<bool> isDestinationSaved(String id);

  // ── Categories ──────────────────────────────────────────────────────────────

  /// All travel mood categories.
  Future<List<Category>> getCategories();

  /// Destinations filtered by mood/category name.
  Future<List<Destination>> getDestinationsByMood(String mood);

  /// Featured / popular destinations for the home feed (limited list).
  Future<List<Destination>> getFeaturedDestinations({int limit = 5});
}

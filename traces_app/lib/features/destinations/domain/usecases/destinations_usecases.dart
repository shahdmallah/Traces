import '../entities/category.dart';
import '../entities/destination.dart';
import '../repositories/i_destinations_repository.dart';

// ---------------------------------------------------------------------------
// GetDestinations
// ---------------------------------------------------------------------------
class GetDestinations {
  const GetDestinations(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call() => _repository.getDestinations();
}

// ---------------------------------------------------------------------------
// GetDestinationById
// ---------------------------------------------------------------------------
class GetDestinationById {
  const GetDestinationById(this._repository);
  final IDestinationsRepository _repository;

  Future<Destination> call(String id) => _repository.getDestinationById(id);
}

// ---------------------------------------------------------------------------
// SearchDestinations
// ---------------------------------------------------------------------------
class SearchDestinations {
  const SearchDestinations(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call(String query) =>
      query.trim().isEmpty
          ? _repository.getDestinations()
          : _repository.searchDestinations(query.trim());
}

// ---------------------------------------------------------------------------
// FilterDestinations
// ---------------------------------------------------------------------------
class FilterDestinations {
  const FilterDestinations(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call({
    String? budget,
    double? minRating,
    List<String>? tags,
  }) =>
      _repository.filterDestinations(
        budget: budget,
        minRating: minRating,
        tags: tags,
      );
}

// ---------------------------------------------------------------------------
// GetSavedDestinations
// ---------------------------------------------------------------------------
class GetSavedDestinations {
  const GetSavedDestinations(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call() => _repository.getSavedDestinations();
}

// ---------------------------------------------------------------------------
// ToggleSaveDestination
// ---------------------------------------------------------------------------
class ToggleSaveDestination {
  const ToggleSaveDestination(this._repository);
  final IDestinationsRepository _repository;

  Future<bool> call(String id) async {
    final saved = await _repository.isDestinationSaved(id);
    if (saved) {
      await _repository.unsaveDestination(id);
      return false;
    } else {
      await _repository.saveDestination(id);
      return true;
    }
  }
}

// ---------------------------------------------------------------------------
// GetCategories
// ---------------------------------------------------------------------------
class GetCategories {
  const GetCategories(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}

// ---------------------------------------------------------------------------
// GetDestinationsByMood
// ---------------------------------------------------------------------------
class GetDestinationsByMood {
  const GetDestinationsByMood(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call(String mood) =>
      _repository.getDestinationsByMood(mood);
}

// ---------------------------------------------------------------------------
// GetFeaturedDestinations
// ---------------------------------------------------------------------------
class GetFeaturedDestinations {
  const GetFeaturedDestinations(this._repository);
  final IDestinationsRepository _repository;

  Future<List<Destination>> call({int limit = 5}) =>
      _repository.getFeaturedDestinations(limit: limit);
}

import '../../domain/entities/category.dart';
import '../models/destination_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract
// ---------------------------------------------------------------------------

/// Swap this implementation for Supabase / REST / GraphQL without touching
/// anything above the data layer.
abstract class IDestinationsRemoteDataSource {
  Future<List<DestinationModel>> getDestinations();
  Future<DestinationModel> getDestinationById(String id);
  Future<List<DestinationModel>> searchDestinations(String query);
  Future<List<DestinationModel>> filterDestinations({
    String? budget,
    double? minRating,
    List<String>? tags,
  });
  Future<List<Category>> getCategories();
  Future<List<DestinationModel>> getDestinationsByMood(String mood);
  Future<List<DestinationModel>> getFeaturedDestinations({int limit = 5});
}

abstract class IDestinationsLocalDataSource {
  Future<List<String>> getSavedIds();
  Future<void> saveDestination(String id);
  Future<void> unsaveDestination(String id);
  Future<bool> isDestinationSaved(String id);
}

// ---------------------------------------------------------------------------
// Mock remote datasource (mirrors the original mock data exactly)
// ---------------------------------------------------------------------------

class DestinationsMockRemoteDataSource implements IDestinationsRemoteDataSource {
  static final List<DestinationModel> _allDestinations = [
    // ---- Explore screen destinations ----
    DestinationModel(
      id: '1',
      name: 'Machu Picchu',
      location: 'Cusco, Peru',
      image: 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=400',
      rating: 4.9,
      reviews: 1234,
      budget: 'Premium',
      distance: 5.2,
      distanceLabel: '5.2 km',
      tags: ['Ruins', 'Mountains', 'Historic'],
      description:
          'An iconic Incan citadel set high in the Andes Mountains, above the Sacred Valley.',
    ),
    DestinationModel(
      id: '2',
      name: 'Santorini',
      location: 'Cyclades, Greece',
      image: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400',
      rating: 4.8,
      reviews: 892,
      budget: 'Luxury',
      distance: 3.1,
      distanceLabel: '3.1 km',
      tags: ['Beach', 'Sunset', 'Romantic'],
      description:
          'Famous for its white-washed buildings, blue domes, and stunning sunsets over the Aegean Sea.',
    ),
    DestinationModel(
      id: '3',
      name: 'Bali',
      location: 'Indonesia',
      image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      rating: 4.7,
      reviews: 2156,
      budget: 'Mid',
      distance: 8.4,
      distanceLabel: '8.4 km',
      tags: ['Beach', 'Culture', 'Relaxing'],
      description:
          'Tropical paradise with beautiful beaches, lush rice terraces, and vibrant culture.',
    ),
    DestinationModel(
      id: '4',
      name: 'Swiss Alps',
      location: 'Switzerland',
      image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400',
      rating: 4.9,
      reviews: 567,
      budget: 'Premium',
      distance: 2.8,
      distanceLabel: '2.8 km',
      tags: ['Mountains', 'Skiing', 'Hiking'],
      description:
          'World-class ski resorts and breathtaking alpine scenery year-round.',
    ),
    DestinationModel(
      id: '5',
      name: 'Kyoto',
      location: 'Japan',
      image: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
      rating: 4.8,
      reviews: 1432,
      budget: 'Mid',
      distance: 12.5,
      distanceLabel: '12.5 km',
      tags: ['Culture', 'Temples', 'Gardens'],
      description:
          'Ancient capital of Japan, renowned for classical Buddhist temples and traditional wooden architecture.',
    ),
    DestinationModel(
      id: '6',
      name: 'Maldives',
      location: 'Indian Ocean',
      image: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400',
      rating: 4.9,
      reviews: 987,
      budget: 'Luxury',
      distance: 15.0,
      distanceLabel: '15.0 km',
      tags: ['Beach', 'Snorkeling', 'Luxury'],
      description:
          'Crystal-clear waters, overwater bungalows, and vibrant coral reefs.',
    ),
    // ---- PlaceCard destinations ----
    DestinationModel(
      id: '7',
      name: 'Banff National Park',
      location: 'Alberta, Canada',
      image: 'https://images.unsplash.com/photo-1536094198093-5f3fc6c9dc5c?w=800',
      rating: 4.8,
      reviews: 12453,
      budget: 'Premium',
      distance: 120,
      distanceLabel: '120 km',
      tags: ['Mountains', 'Hiking', 'Lakes'],
      description:
          'Experience the breathtaking beauty of the Canadian Rockies with turquoise lakes, majestic mountains, and abundant wildlife.',
    ),
    // ---- HomeScreen destinations ----
    DestinationModel(
      id: '8',
      name: 'Manarola',
      location: 'Italia',
      image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
      rating: 4.8,
      reviews: 1243,
      budget: '',
      distance: 2.5,
      distanceLabel: '2.5 km',
      tags: ['Culture'],
      description: 'Colorful cliffside village in Cinque Terre with stunning sea views and charming streets.',
    ),
    DestinationModel(
      id: '9',
      name: 'Phi Phi Islands',
      location: 'Thailand',
      image: 'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=600',
      rating: 4.9,
      reviews: 2847,
      budget: '',
      distance: 3.0,
      distanceLabel: '3 km',
      tags: ['Beach'],
      description: 'Paradise islands with crystal clear waters, limestone cliffs, and vibrant marine life.',
    ),
    DestinationModel(
      id: '10',
      name: 'Dubai',
      location: 'UAE',
      image: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=600',
      rating: 4.7,
      reviews: 3421,
      budget: '',
      distance: 5.0,
      distanceLabel: '5 km',
      tags: ['Urban'],
      description: 'Futuristic city with stunning architecture, luxury shopping, and desert adventures.',
    ),
    DestinationModel(
      id: '11',
      name: 'Tokyo',
      location: 'Japan',
      image: 'https://images.unsplash.com/photo-1555939594-58d7cb561629?w=600',
      rating: 4.9,
      reviews: 5678,
      budget: '',
      distance: 4.0,
      distanceLabel: '4 km',
      tags: ['Urban'],
      description: 'Vibrant metropolis blending ultramodern and traditional Japanese culture.',
    ),
    DestinationModel(
      id: '12',
      name: 'Bali',
      location: 'Indonesia',
      image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600',
      rating: 4.8,
      reviews: 3891,
      budget: '',
      distance: 3.5,
      distanceLabel: '3.5 km',
      tags: ['Beach'],
      description: 'Island paradise known for volcanic mountains, rice terraces, and beautiful beaches.',
    ),
  ];

  @override
  Future<List<DestinationModel>> getDestinations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_allDestinations);
  }

  @override
  Future<DestinationModel> getDestinationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final dest = _allDestinations.firstWhere(
      (d) => d.id == id,
      orElse: () => throw Exception('Destination not found: $id'),
    );
    return dest;
  }

  @override
  Future<List<DestinationModel>> searchDestinations(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _allDestinations
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.location.toLowerCase().contains(q) ||
            d.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Future<List<DestinationModel>> filterDestinations({
    String? budget,
    double? minRating,
    List<String>? tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allDestinations.where((d) {
      if (budget != null &&
          d.budget.toLowerCase() != budget.toLowerCase()) {
        return false;
      }
      if (minRating != null && d.rating < minRating) return false;
      if (tags != null && tags.isNotEmpty) {
        if (!tags.any((t) =>
            d.tags.map((e) => e.toLowerCase()).contains(t.toLowerCase()))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      Category(id: '1', name: 'Adventure', icon: 'mountain'),
      Category(id: '2', name: 'Beach', icon: 'palmtree'),
      Category(id: '3', name: 'Culture', icon: 'landmark'),
      Category(id: '4', name: 'Urban', icon: 'building'),
      Category(id: '5', name: 'Nature', icon: 'leaf'),
    ];
  }

  @override
  Future<List<DestinationModel>> getDestinationsByMood(String mood) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allDestinations
        .where((d) => d.tags.any(
            (t) => t.toLowerCase() == mood.toLowerCase()))
        .toList();
  }

  @override
  Future<List<DestinationModel>> getFeaturedDestinations(
      {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = List<DestinationModel>.from(_allDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }
}

// ---------------------------------------------------------------------------
// In-memory local datasource (replace with Hive / SharedPreferences / Isar)
// ---------------------------------------------------------------------------

class DestinationsInMemoryLocalDataSource
    implements IDestinationsLocalDataSource {
  final Set<String> _savedIds = {'1', '2', '3', '4'}; // mirrors saved_screen mock

  @override
  Future<List<String>> getSavedIds() async => List.from(_savedIds);

  @override
  Future<void> saveDestination(String id) async => _savedIds.add(id);

  @override
  Future<void> unsaveDestination(String id) async => _savedIds.remove(id);

  @override
  Future<bool> isDestinationSaved(String id) async => _savedIds.contains(id);
}

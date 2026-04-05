import 'package:traces_app/shared/models/trip.dart';

/// Mock data for trips - moved from hardcoded screen data
class TripsMockData {
  static final List<Trip> trips = [
    Trip(
      id: '1',
      name: 'Machu Picchu',
      location: 'Cusco, Peru',
      image: 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=400',
      rating: 4.9,
      reviews: 1234,
      budget: 'Premium',
      distance: 5.2,
    ),
    Trip(
      id: '2',
      name: 'Santorini',
      location: 'Cyclades, Greece',
      image: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400',
      rating: 4.8,
      reviews: 892,
      budget: 'Luxury',
      distance: 3.1,
    ),
    Trip(
      id: '3',
      name: 'Bali',
      location: 'Indonesia',
      image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      rating: 4.7,
      reviews: 2156,
      budget: 'Mid',
      distance: 8.4,
    ),
    Trip(
      id: '4',
      name: 'Swiss Alps',
      location: 'Switzerland',
      image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400',
      rating: 4.9,
      reviews: 567,
      budget: 'Premium',
      distance: 2.8,
    ),
    Trip(
      id: '5',
      name: 'Kyoto',
      location: 'Japan',
      image: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
      rating: 4.8,
      reviews: 1432,
      budget: 'Mid',
      distance: 12.5,
    ),
    Trip(
      id: '6',
      name: 'Maldives',
      location: 'Indian Ocean',
      image: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400',
      rating: 4.9,
      reviews: 987,
      budget: 'Luxury',
      distance: 15.0,
    ),
  ];

  /// Get all trips
  static Future<List<Trip>> fetchAll() async {
    return trips;
  }

  /// Get single trip by ID
  static Future<Trip?> fetchById(String id) async {
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search trips by name or location
  static Future<List<Trip>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    return trips
        .where((trip) =>
            trip.name.toLowerCase().contains(lowerQuery) ||
            trip.location.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter trips by budget
  static Future<List<Trip>> filterByBudget(String budget) async {
    return trips.where((trip) => trip.budget == budget).toList();
  }

  /// Sort trips
  static Future<List<Trip>> sortTrips({
    bool byRating = true,
    bool ascending = false,
  }) async {
    final sorted = List<Trip>.from(trips);
    if (byRating) {
      sorted.sort((a, b) =>
          ascending ? a.rating.compareTo(b.rating) : b.rating.compareTo(a.rating));
    } else {
      sorted.sort((a, b) =>
          ascending ? a.reviews.compareTo(b.reviews) : b.reviews.compareTo(a.reviews));
    }
    return sorted;
  }

  /// Filter trips by max distance
  static Future<List<Trip>> filterByDistance(double maxDistance) async {
    return trips.where((trip) => trip.distance <= maxDistance).toList();
  }

  /// Combined filter: budget and/or distance with sorting
  static Future<List<Trip>> filterAndSort({
    String? budget,
    double? maxDistance,
    bool byRating = true,
    bool ascending = false,
  }) async {
    var filtered = List<Trip>.from(trips);

    if (budget != null) {
      filtered = filtered.where((trip) => trip.budget == budget).toList();
    }

    if (maxDistance != null) {
      filtered = filtered.where((trip) => trip.distance <= maxDistance).toList();
    }

    if (byRating) {
      filtered.sort((a, b) =>
          ascending ? a.rating.compareTo(b.rating) : b.rating.compareTo(a.rating));
    } else {
      filtered.sort((a, b) =>
          ascending ? a.reviews.compareTo(b.reviews) : b.reviews.compareTo(a.reviews));
    }

    return filtered;
  }
}

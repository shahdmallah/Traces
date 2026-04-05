import 'package:traces_app/shared/models/destination.dart';

/// Mock data for destinations - moved from hardcoded screen data
class DestinationsMockData {
  static final List<Destination> destinations = [
    Destination(
      id: '1',
      name: 'Banff National Park',
      location: 'Alberta, Canada',
      image: 'https://images.unsplash.com/photo-1536094198093-5f3fc6c9dc5c?w=500',
      rating: 4.8,
      budget: '\$',
      reviews: 12453,
      tags: ['Mountains', 'Hiking'],
      description: 'Beautiful mountain scenery',
    ),
    Destination(
      id: '2',
      name: 'Santorini',
      location: 'Greece',
      image: 'https://images.unsplash.com/photo-1613395877344-13a4a3c2c8c7?w=500',
      rating: 4.9,
      budget: '\$\$',
      reviews: 8932,
      tags: ['Beach', 'Romantic'],
      description: 'Stunning sunsets',
    ),
    Destination(
      id: '3',
      name: 'Kyoto',
      location: 'Japan',
      image: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500',
      rating: 4.7,
      budget: '\$\$',
      reviews: 7234,
      tags: ['Culture', 'Temples'],
      description: 'Ancient capital of Japan',
    ),
    Destination(
      id: '4',
      name: 'Swiss Alps',
      location: 'Switzerland',
      image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
      rating: 4.9,
      budget: '\$\$\$\$',
      reviews: 5621,
      tags: ['Mountains', 'Skiing'],
      description: 'Breathtaking alpine views',
    ),
  ];

  /// Get all destinations
  static Future<List<Destination>> fetchAll() async {
    return destinations;
  }

  /// Get single destination by ID
  static Future<Destination?> fetchById(String id) async {
    try {
      return destinations.firstWhere((dest) => dest.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search destinations
  static Future<List<Destination>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    return destinations
        .where((d) =>
            d.name.toLowerCase().contains(lowerQuery) ||
            d.location.toLowerCase().contains(lowerQuery) ||
            d.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Filter destinations
  static Future<List<Destination>> filter({
    String? budget,
    double? minRating,
    List<String>? tags,
  }) async {
    return destinations.where((d) {
      if (budget != null && d.budget != budget) return false;
      if (minRating != null && d.rating < minRating) return false;
      if (tags != null && tags.isNotEmpty) {
        final hasTag = d.tags.any((tag) => tags.contains(tag));
        if (!hasTag) return false;
      }
      return true;
    }).toList();
  }
}

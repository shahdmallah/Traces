import 'package:traces_app/shared/models/media.dart';

/// Mock data for media
class MediaMockData {
  static final List<Media> media = [
    Media(
      id: '1',
      title: 'Mountain Sunset',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      category: 'Nature',
      uploadedDate: DateTime.now().subtract(const Duration(days: 5)),
      likes: 234,
      comments: 18,
    ),
    Media(
      id: '2',
      title: 'Beach Paradise',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
      category: 'Travel',
      uploadedDate: DateTime.now().subtract(const Duration(days: 3)),
      likes: 567,
      comments: 42,
    ),
    Media(
      id: '3',
      title: 'Urban Architecture',
      imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
      category: 'City',
      uploadedDate: DateTime.now().subtract(const Duration(days: 2)),
      likes: 345,
      comments: 28,
    ),
    Media(
      id: '4',
      title: 'Forest Path',
      imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
      category: 'Nature',
      uploadedDate: DateTime.now().subtract(const Duration(days: 1)),
      likes: 456,
      comments: 35,
    ),
    Media(
      id: '5',
      title: 'City Lights',
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
      category: 'City',
      uploadedDate: DateTime.now().subtract(const Duration(hours: 12)),
      likes: 678,
      comments: 52,
    ),
    Media(
      id: '6',
      title: 'Ocean Waves',
      imageUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=400',
      category: 'Travel',
      uploadedDate: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 789,
      comments: 61,
    ),
  ];

  /// Get all media
  static Future<List<Media>> fetchAll() async {
    return media;
  }

  /// Get media by category
  static Future<List<Media>> fetchByCategory(String category) async {
    return media.where((m) => m.category == category).toList();
  }

  /// Search media
  static Future<List<Media>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    return media
        .where((m) =>
            m.title.toLowerCase().contains(lowerQuery) ||
            m.category.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

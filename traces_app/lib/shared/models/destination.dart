/// Destination model - shared across layers
class Destination {
  final String id;
  final String name;
  final String location;
  final String image;
  final double rating;
  final String budget; // e.g., '$', '$$', '$$$'
  final int reviews;
  final List<String> tags;
  final String description;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    required this.budget,
    required this.reviews,
    required this.tags,
    required this.description,
  });

  /// Convert to JSON for API compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image': image,
      'rating': rating,
      'budget': budget,
      'reviews': reviews,
      'tags': tags,
      'description': description,
    };
  }

  /// Create from JSON response
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      budget: json['budget'] as String,
      reviews: json['reviews'] as int,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
    );
  }

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? image,
    double? rating,
    String? budget,
    int? reviews,
    List<String>? tags,
    String? description,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      budget: budget ?? this.budget,
      reviews: reviews ?? this.reviews,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }
}

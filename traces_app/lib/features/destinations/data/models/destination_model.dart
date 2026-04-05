import '../../domain/entities/destination.dart';

/// Data-layer model. Handles JSON serialisation and maps to the
/// domain [Destination] entity. Swap this for generated code (json_serializable,
/// freezed, etc.) whenever you like — the rest of the architecture is unaffected.
class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.location,
    required super.image,
    required super.rating,
    required super.reviews,
    required super.budget,
    required super.distance,
    super.distanceLabel,
    super.tags,
    super.description,
    super.savedDate,
  });

  // -------------------------------------------------------------------------
  // JSON
  // -------------------------------------------------------------------------

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int? ?? 0,
      budget: json['budget'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      distanceLabel: json['distance_label'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      description: json['description'] as String? ?? '',
      savedDate: json['saved_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'image': image,
        'rating': rating,
        'reviews': reviews,
        'budget': budget,
        'distance': distance,
        'distance_label': distanceLabel,
        'tags': tags,
        'description': description,
        if (savedDate != null) 'saved_date': savedDate,
      };

  // -------------------------------------------------------------------------
  // Factory helpers
  // -------------------------------------------------------------------------

  /// Convert a domain entity back to a model (useful for caching).
  factory DestinationModel.fromEntity(Destination entity) {
    return DestinationModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      image: entity.image,
      rating: entity.rating,
      reviews: entity.reviews,
      budget: entity.budget,
      distance: entity.distance,
      distanceLabel: entity.distanceLabel,
      tags: entity.tags,
      description: entity.description,
      savedDate: entity.savedDate,
    );
  }
}

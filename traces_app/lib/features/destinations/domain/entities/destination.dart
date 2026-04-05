/// Core Destination entity — used by all layers.
/// No Flutter / framework dependencies here.
class Destination {
  final String id;
  final String name;
  final String location;
  final String image;
  final double rating;
  final int reviews;
  final String budget;
  final double distance;
  final String distanceLabel; // e.g. "120 km"
  final List<String> tags;
  final String description;
  final String? savedDate; // non-null when loaded from saved list

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.budget,
    required this.distance,
    this.distanceLabel = '',
    this.tags = const [],
    this.description = '',
    this.savedDate,
  });

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? image,
    double? rating,
    int? reviews,
    String? budget,
    double? distance,
    String? distanceLabel,
    List<String>? tags,
    String? description,
    String? savedDate,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      budget: budget ?? this.budget,
      distance: distance ?? this.distance,
      distanceLabel: distanceLabel ?? this.distanceLabel,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      savedDate: savedDate ?? this.savedDate,
    );
  }
}

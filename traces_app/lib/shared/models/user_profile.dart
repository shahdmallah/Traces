/// User profile model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String bio;
  final int tripsCompleted;
  final int reviewsCount;
  final double averageRating;
  final List<String> interests;
  final bool verified;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.bio,
    required this.tripsCompleted,
    required this.reviewsCount,
    required this.averageRating,
    required this.interests,
    required this.verified,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
        'bio': bio,
        'tripsCompleted': tripsCompleted,
        'reviewsCount': reviewsCount,
        'averageRating': averageRating,
        'interests': interests,
        'verified': verified,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatar: json['avatar'],
        bio: json['bio'],
        tripsCompleted: json['tripsCompleted'],
        reviewsCount: json['reviewsCount'],
        averageRating: json['averageRating'],
        interests: List<String>.from(json['interests']),
        verified: json['verified'],
      );
}

import 'package:traces_app/shared/models/user_profile.dart';

class ProfileMockData {
  static final UserProfile currentUser = UserProfile(
    id: 'user_1',
    name: 'John Traveler',
    email: 'john@travels.com',
    avatar: 'https://i.pravatar.cc/150?img=33',
    bio: 'Exploring the world one destination at a time',
    tripsCompleted: 12,
    reviewsCount: 28,
    averageRating: 4.8,
    interests: ['Mountains', 'Beaches', 'Culture', 'Food'],
    verified: true,
  );

  static Future<UserProfile> fetchProfile() async => currentUser;

  static Future<UserProfile?> fetchProfileById(String id) async {
    if (id == 'user_1') return currentUser;
    return null;
  }
}

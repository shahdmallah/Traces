import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traces_app/features/profile/data/repositories/profile_repository.dart';
import 'package:traces_app/shared/models/user_profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final response = await ref.watch(profileRepositoryProvider).getProfile();
  if (response.isError) throw Exception(response.error);
  return response.data ?? (throw Exception('No profile data'));
});

final userProfileByIdProvider =
    FutureProvider.family<UserProfile, String>((ref, id) async {
  final response = await ref.watch(profileRepositoryProvider).getProfileById(id);
  if (response.isError) throw Exception(response.error);
  return response.data ?? (throw Exception('No profile data'));
});

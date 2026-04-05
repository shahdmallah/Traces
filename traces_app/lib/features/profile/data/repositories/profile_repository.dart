import 'package:traces_app/shared/data/models/api_response.dart';
import 'package:traces_app/shared/models/user_profile.dart';
import 'package:traces_app/features/profile/data/datasources/profile_remote_datasource.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository({ProfileRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSourceImpl();

  Future<ApiResponse<UserProfile>> getProfile() async {
    try {
      return await _remoteDataSource.getProfile();
    } catch (e) {
      return ApiResponse.error('Failed to fetch profile: $e');
    }
  }

  Future<ApiResponse<UserProfile>> getProfileById(String id) async {
    try {
      if (id.isEmpty) return ApiResponse.error('Invalid profile ID');
      return await _remoteDataSource.getProfileById(id);
    } catch (e) {
      return ApiResponse.error('Failed to fetch profile: $e');
    }
  }
}

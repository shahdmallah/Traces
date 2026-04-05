import 'package:traces_app/shared/data/models/api_response.dart';
import 'package:traces_app/shared/models/user_profile.dart';
import 'package:traces_app/shared/services/base_mock_service.dart';
import 'package:traces_app/data/mocks/profile_mock.dart';

abstract class ProfileRemoteDataSource {
  Future<ApiResponse<UserProfile>> getProfile();
  Future<ApiResponse<UserProfile>> getProfileById(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final _mockService = ProfileMockService();

  @override
  Future<ApiResponse<UserProfile>> getProfile() => _mockService.fetchProfile();

  @override
  Future<ApiResponse<UserProfile>> getProfileById(String id) =>
      _mockService.fetchProfileById(id);
}

class ProfileMockService extends BaseMockService {
  Future<ApiResponse<UserProfile>> fetchProfile() =>
      mockApiCall(() => ProfileMockData.fetchProfile());

  Future<ApiResponse<UserProfile>> fetchProfileById(String id) =>
      mockApiCall(() async {
        final profile = await ProfileMockData.fetchProfileById(id);
        if (profile == null) throw Exception('Profile not found');
        return profile;
      });
}

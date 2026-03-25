import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

/// Handles profile API reads/writes.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileModel> getProfile(String uid) async {
    try {
      final response = await _apiClient.getJson('users/$uid');
      return ProfileModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to load profile.', e);
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _apiClient.putJson(
        'users/${profile.uid}',
        body: profile.toJson(),
      );
      return ProfileModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to update profile.', e);
    }
  }
}

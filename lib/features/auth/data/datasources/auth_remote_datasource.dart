import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Performs authentication API calls and translates failures into [AuthException].
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJson(
        'auth/signin',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );
      final token = response['token'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;
      if (token == null || userJson == null) {
        throw const AuthException('Invalid sign-in response.');
      }
      await _apiClient.writeToken(token);
      return UserModel.fromJson(userJson);
    } on AppException catch (e) {
      throw AuthException(e.message ?? 'Sign-in failed.', e);
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJson(
        'auth/signup',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );
      final token = response['token'] as String?;
      final userJson = response['user'] as Map<String, dynamic>?;
      if (token == null || userJson == null) {
        throw const AuthException('Invalid sign-up response.');
      }
      await _apiClient.writeToken(token);
      return UserModel.fromJson(userJson);
    } on AppException catch (e) {
      throw AuthException(e.message ?? 'Sign-up failed.', e);
    }
  }

  Future<void> signOut() async {
    try {
      await _apiClient.clearToken();
    } on AppException catch (e) {
      throw AuthException(e.message ?? 'Sign-out failed.', e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.getJson('auth/me');
      return UserModel.fromJson(response);
    } on AppException {
      return null;
    }
  }
}

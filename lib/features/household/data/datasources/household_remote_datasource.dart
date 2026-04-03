import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/household_model.dart';
import '../models/member_model.dart';

/// Handles household API reads/writes.
class HouseholdRemoteDataSource {
  const HouseholdRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<HouseholdModel> createHousehold(String name) async {
    try {
      final response = await _apiClient.postJson(
        'households',
        body: {'name': name},
      );
      return HouseholdModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to create household.', e);
    }
  }

  Future<HouseholdModel> joinHousehold(String inviteCode) async {
    try {
      final response = await _apiClient.postJson(
        'households/join',
        body: {'inviteCode': inviteCode},
      );
      return HouseholdModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to join household.', e);
    }
  }

  Future<HouseholdModel> getHousehold(String id) async {
    try {
      final response = await _apiClient.getJson('households/$id');
      return HouseholdModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to load household.', e);
    }
  }

  Future<List<MemberModel>> getMembers(String householdId) async {
    try {
      final response =
          await _apiClient.getJsonList('households/$householdId/members');
      return response
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException catch (e) {
      throw ApiException('Failed to load members.', e);
    }
  }

  Future<void> removeMember(String householdId, String userId) async {
    try {
      await _apiClient.delete('households/$householdId/members/$userId');
    } on AppException catch (e) {
      throw ApiException('Failed to remove member.', e);
    }
  }

  Future<void> deleteHousehold(String id) async {
    try {
      await _apiClient.delete('households/$id');
    } on AppException catch (e) {
      throw ApiException('Failed to delete household.', e);
    }
  }
}

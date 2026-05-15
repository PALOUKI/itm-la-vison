import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/user.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProfileRepository(apiService: apiService);
});

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<User> getProfile() async {
    try {
      return await _apiService.getProfile();
    } catch (e) {
      rethrow;
    }
  }
}

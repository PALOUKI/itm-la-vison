import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/user.dart';

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

import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/dashboard_response.dart';

class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<DashboardResponse> getDashboard() async {
    try {
      final responseData = await _apiService.getDashboard();
      return DashboardResponse.fromJson(responseData['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/dashboard_response.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DashboardRepository(apiService: apiService);
});

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

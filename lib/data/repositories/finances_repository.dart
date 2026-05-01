import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/finance.dart';

class FinancesRepository {
  final ApiService _apiService;

  FinancesRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<FinancesResponse> getFinances() async {
    try {
      return await _apiService.getFinances();
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/finance.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final financesRepositoryProvider = Provider<FinancesRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FinancesRepository(apiService: apiService);
});

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

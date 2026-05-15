import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/grades.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final gradesRepositoryProvider = Provider<GradesRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GradesRepository(apiService: apiService);
});

class GradesRepository {
  final ApiService _apiService;

  GradesRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<GradesResponse> getGrades(String studentUuid) async {
    try {
      return await _apiService.getGrades(studentUuid);
    } catch (e) {
      rethrow;
    }
  }
}


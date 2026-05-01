import 'package:vision/core/services/api_service.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/grades.dart';

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


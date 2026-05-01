import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/timetable.dart';

class TimetableRepository {
  final ApiService _apiService;

  TimetableRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<TimetableResponse> getTimetable(String studentUuid) async {
    try {
      return await _apiService.getTimetable(studentUuid);
    } catch (e) {
      rethrow;
    }
  }
}


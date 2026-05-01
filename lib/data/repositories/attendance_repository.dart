import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/attendance.dart';

class AttendanceRepository {
  final ApiService _apiService;

  AttendanceRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<AttendanceResponse> getAttendances(
    String studentUuid, {
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _apiService.getAttendances(
        studentUuid,
        month: month,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AttendanceRepository(apiService: apiService);
});

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


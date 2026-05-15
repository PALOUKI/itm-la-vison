import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/timetable.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TimetableRepository(apiService: apiService);
});

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


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/attendance_repository.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Provider pour récupérer les absences d'un élève
final attendanceProvider = FutureProvider.family<AttendanceResponse, String>((ref, studentUuid) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getAttendances(studentUuid);
});

// Provider pour récupérer les absences avec des paramètres personnalisés
final attendanceWithFiltersProvider =
    FutureProvider.family<AttendanceResponse, ({String studentUuid, String? month, String? startDate, String? endDate})>(
  (ref, params) async {
    final repository = ref.watch(attendanceRepositoryProvider);
    return repository.getAttendances(
      params.studentUuid,
      month: params.month,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

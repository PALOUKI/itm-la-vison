import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/grades_repository.dart';
import 'package:vision/domain/models/grades.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Provider pour le repository de grades
final gradesRepositoryProvider = Provider<GradesRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GradesRepository(apiService: apiService);
});

// Provider pour récupérer les grades d'un élève
final gradesProvider = FutureProvider.family<GradesResponse, String>((ref, studentUuid) async {
  final repository = ref.watch(gradesRepositoryProvider);
  return repository.getGrades(studentUuid);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/grades_repository.dart';
import 'package:vision/domain/models/grades.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Provider pour récupérer les grades d'un élève
final gradesProvider = FutureProvider.autoDispose.family<GradesResponse, String>((ref, studentUuid) async {
  final repository = ref.watch(gradesRepositoryProvider);
  return repository.getGrades(studentUuid);
});


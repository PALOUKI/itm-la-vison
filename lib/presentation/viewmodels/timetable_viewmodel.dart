import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/timetable_repository.dart';
import 'package:vision/domain/models/timetable.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Provider pour récupérer l'emploi du temps d'un élève
final timetableProvider = FutureProvider.autoDispose.family<TimetableResponse, String>((ref, studentUuid) async {
  final repository = ref.watch(timetableRepositoryProvider);
  return repository.getTimetable(studentUuid);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/data/repositories/bulletins_repository.dart';
import 'package:vision/domain/models/bulletins.dart';
import 'package:vision/domain/models/common_models.dart';

/// Provider pour le repository des bulletins
final bulletinsRepositoryProvider = Provider<BulletinsRepository>((ref) {
  return BulletinsRepository(apiService: ApiService());
});

/// Alias pour corriger la typo utilisée dans certains fichiers
final bullletinsRepositoryProvider = bulletinsRepositoryProvider;

/// Provider pour récupérer tous les bulletins (utilisé dans le dashboard/détail enfant)
final bulletinsProvider = FutureProvider<BulletinsResponse>((ref) async {
  final repository = ref.watch(bulletinsRepositoryProvider);
  return repository.getBulletins();
});

/// Provider pour les périodes (semestres/trimestres)
final periodsProvider = FutureProvider<List<Period>>((ref) async {
  ref.keepAlive();
  final repository = ref.watch(bulletinsRepositoryProvider);
  return repository.getPeriods();
});

/// Provider pour les examens d'une période donnée
final examsProvider = FutureProvider.family<List<Exam>, int>((ref, periodId) async {
  final repository = ref.watch(bulletinsRepositoryProvider);
  return repository.getExams(periodId: periodId);
});

/// Paramètres pour le bulletin HTML
class BulletinParams {
  final String studentUuid;
  final int periodId;

  BulletinParams({required this.studentUuid, required this.periodId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulletinParams &&
          runtimeType == other.runtimeType &&
          studentUuid == other.studentUuid &&
          periodId == other.periodId;

  @override
  int get hashCode => studentUuid.hashCode ^ periodId.hashCode;
}

/// Provider pour le contenu HTML du bulletin général
final bulletinHtmlProvider = FutureProvider.family<String, BulletinParams>((ref, params) async {
  ref.keepAlive();
  final repository = ref.watch(bulletinsRepositoryProvider);
  return repository.getBulletinHtml(
    studentUuid: params.studentUuid,
    periodId: params.periodId,
  );
});

/// Paramètres pour le mini-bulletin HTML
class MiniBulletinParams {
  final String studentUuid;
  final int examId;

  MiniBulletinParams({required this.studentUuid, required this.examId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiniBulletinParams &&
          runtimeType == other.runtimeType &&
          studentUuid == other.studentUuid &&
          examId == other.examId;

  @override
  int get hashCode => studentUuid.hashCode ^ examId.hashCode;
}

/// Provider pour le contenu HTML du mini-bulletin (compositions)
final miniBulletinHtmlProvider = FutureProvider.family<String, MiniBulletinParams>((ref, params) async {
  ref.keepAlive();
  final repository = ref.watch(bulletinsRepositoryProvider);
  return repository.getMiniBulletinHtml(
    studentUuid: params.studentUuid,
    examId: params.examId,
  );
});

import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/bulletins.dart';
import 'package:vision/domain/models/common_models.dart';

class BulletinsRepository {
  final ApiService apiService;

  BulletinsRepository({required this.apiService});

  Future<BulletinsResponse> getBulletins() async {
    return apiService.getBulletins();
  }

  Future<List<Period>> getPeriods() async {
    return await apiService.getPeriods();
  }

  Future<List<Exam>> getExams({int? periodId}) async {
    return await apiService.getExams(periodId: periodId);
  }

  Future<String> getBulletinHtml({
    required String studentUuid,
    required int periodId,
  }) async {
    return apiService.getBulletinHtml(
      studentUuid: studentUuid,
      periodId: periodId,
    );
  }

  Future<String> getMiniBulletinHtml({
    required String studentUuid,
    required int examId,
  }) async {
    return apiService.getMiniBulletinHtml(
      studentUuid: studentUuid,
      examId: examId,
    );
  }

  Future<List<int>> downloadBulletinPdf({
    required String studentUuid,
    required String periodId,
  }) async {
    return apiService.downloadBulletinPdf(
      studentUuid: studentUuid,
      periodId: periodId,
    );
  }
}




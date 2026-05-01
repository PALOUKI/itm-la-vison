import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/message.dart';

class MessagesRepository {
  final ApiService _apiService;

  MessagesRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<MessagingResponse> getMessages() async {
    try {
      return await _apiService.getMessages();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Teacher>> getChildTeachers(String childUuid) async {
    try {
      final data = await _apiService.getChildTeachers(childUuid);
      final list = data as List<dynamic>? ?? [];
      return list.map((e) => Teacher.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String recipientType,
    int? teacherId,
    int? studentId,
    required String subject,
    required String body,
  }) async {
    try {
      await _apiService.sendMessage(
        recipientType: recipientType,
        teacherId: teacherId,
        studentId: studentId,
        subject: subject,
        body: body,
      );
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_endpoints.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MessagesRepository(apiService: apiService);
});

class MessagesRepository {
  final ApiService _apiService;

  MessagesRepository({required ApiService apiService}) : _apiService = apiService;

  // ============================================
  // MESSAGES (CHATS)
  // ============================================

  Future<MessagingResponse> getMessages() async {
    final data = await _apiService.getMessages();
    if (data is Map<String, dynamic>) {
      return MessagingResponse.fromJson(data);
    } else if (data is List<dynamic>) {
      return MessagingResponse(sent: [], received: [], teachers: []);
    }
    throw Exception('Format de messages invalide');
  }

  Future<List<Teacher>> getChildTeachers(String childUuid) async {
    final response = await _apiService.getChildTeachers(childUuid);
    if (response is List) {
      return response.map((e) => Teacher.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> sendMessage({
    required String recipientType,
    int? teacherId,
    int? studentId,
    required String subject,
    required String body,
  }) async {
    await _apiService.sendMessage(
      recipientType: recipientType,
      teacherId: teacherId,
      studentId: studentId,
      subject: subject,
      body: body,
    );
  }

  // ============================================
  // NOTIFICATIONS
  // ============================================

  Future<NotificationsResponse> getNotifications({int page = 1}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.getNotifications,
        queryParameters: {'page': page},
      );
      if (response.data != null) {
        return NotificationsResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Données de notifications vides');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String uuid) async {
    try {
      // Correction: utiliser data: {} car post attend un paramètre nommé data
      await _apiService.post(ApiEndpoints.markNotificationRead(uuid), data: {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _apiService.put(
        ApiEndpoints.updateFcmToken,
        {'fcm_token': token},
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du token FCM: $e');
    }
  }
}

// Pour la compatibilité avec le code existant
typedef NotificationsRepository = MessagesRepository;

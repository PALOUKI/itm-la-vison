import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/announcement.dart';

class AnnouncementsRepository {
  final ApiService _apiService;

  AnnouncementsRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<AnnouncementsResponse> getParentAnnouncements() async {
    try {
      return await _apiService.getParentAnnouncements();
    } catch (e) {
      rethrow;
    }
  }
}

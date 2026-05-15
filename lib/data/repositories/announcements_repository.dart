import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/announcement.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AnnouncementsRepository(apiService: apiService);
});

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

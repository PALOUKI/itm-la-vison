import 'package:vision/core/services/api_service.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/children_response.dart';

class ChildrenRepository {
  final ApiService _apiService;

  ChildrenRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ChildrenResponse> getChildren() async {
    try {
      return await _apiService.getChildren();
    } catch (e) {
      rethrow;
    }
  }

  Future<Child> getChildDetails(String childUuid) async {
    try {
      return await _apiService.getChildDetails(childUuid);
    } catch (e) {
      rethrow;
    }
  }
}

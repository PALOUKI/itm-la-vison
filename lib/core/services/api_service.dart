import 'package:dio/dio.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/api_endpoints.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/children_response.dart' as children_response;
import 'package:vision/domain/models/login_response.dart';
import 'package:vision/domain/models/announcement.dart';
import 'package:vision/domain/models/attendance.dart' as attendance_model;
import 'package:vision/domain/models/timetable.dart' as timetable_model;
import 'package:vision/domain/models/grades.dart' as grades_model;
import 'package:vision/domain/models/bulletins.dart' as bulletins_model;
import 'package:vision/domain/models/finance.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/domain/models/user.dart';
import 'package:vision/domain/models/common_models.dart';

class ApiService {
  late Dio _dio;
  String? _authToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true, // Crucial pour avoir le JSON du 403
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Ajouter un interceptor pour les logs
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  /// Définir le token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Récupérer le token
  String? getAuthToken() => _authToken;

  /// Réinitialiser le token
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// Login endpoint
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Login failed with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Current User (/auth/me)
  Future<User> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch user profile data');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get dashboard endpoint
  Future<dynamic> getDashboard() async {
    try {
      final response = await _dio.get(ApiEndpoints.dashboard);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch dashboard');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get children endpoint
  Future<children_response.ChildrenResponse> getChildren() async {
    try {
      final response = await _dio.get(ApiEndpoints.getChildren);

      if (response.statusCode == 200) {
        final responseData = response.data['data'];

        if (responseData is List) {
          final children = responseData
              .map((e) => Child.fromJson(e as Map<String, dynamic>))
              .toList();
          // The API response is a list of children, so we create a dummy AcademicYear
          // A proper solution would be to get the current academic year from another endpoint
          final currentYear = children_response.AcademicYear(
            id: 0,
            uuid: '',
            name: '2023-2024', // Dummy data
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            isCurrent: true,
          );
          return children_response.ChildrenResponse(currentYear: currentYear, children: children);
        } else {
          throw Exception('Invalid data format received from server');
        }
      } else {
        throw Exception('Failed to fetch children with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get child details endpoint
  Future<Child> getChildDetails(String childUuid) async {
    try {
      final response = await _dio.get(ApiEndpoints.getChildDetails(childUuid));

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Child.fromJson(data);
      } else {
        throw Exception('Failed to fetch child details with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get parent announcements
  Future<AnnouncementsResponse> getParentAnnouncements() async {
    try {
      final response = await _dio.get(ApiEndpoints.announcements);
      if (response.statusCode == 200) {
        return AnnouncementsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch announcements with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Finance summary
  Future<FinancesResponse> getFinances() async {
    try {
      final response = await _dio.get(ApiEndpoints.getFinances);
      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        return FinancesResponse.fromJsonList(dataList);
      } else {
        throw Exception('Failed to fetch finances');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Messages
  Future<MessagingResponse> getMessages() async {
    try {
      final response = await _dio.get(ApiEndpoints.messages);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Handle both Map and List responses dynamically
        if (data is Map<String, dynamic>) {
          return MessagingResponse.fromJson(data);
        } else if (data is List<dynamic>) {
          // If it's a list, return empty response or handle as needed
          return MessagingResponse(
            sent: [],
            received: [],
            teachers: [],
          );
        } else {
          throw Exception('Invalid messages data format');
        }
      } else {
        throw Exception('Failed to fetch messages');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Profile
  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.getProfile);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Handle both Map and dynamic responses
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        } else {
          throw Exception('Invalid profile data format');
        }
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get teachers for a child
  Future<dynamic> getChildTeachers(String childUuid) async {
    try {
      final response = await _dio.get(ApiEndpoints.getChildTeachers(childUuid));
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch teachers');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String recipientType, // 'teacher' or 'administration'
    int? teacherId,
    int? studentId,
    required String subject,
    required String body,
  }) async {
    try {
      final data = <String, dynamic>{
        'recipient_type': recipientType,
        'subject': subject,
        'body': body,
      };
      if (teacherId != null) data['teacher_id'] = teacherId;
      if (studentId != null) data['student_id'] = studentId;

      await _dio.post(ApiEndpoints.messages, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Logout endpoint
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
      clearAuthToken();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Refresh token endpoint
  Future<String> refreshToken() async {
    try {
      final response = await _dio.post(ApiEndpoints.refreshToken);
      if (response.statusCode == 200) {
        final token = response.data['data']['token'] as String;
        setAuthToken(token);
        return token;
      } else {
        throw Exception('Token refresh failed');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic GET request
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic POST request
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Attendances for a student
  Future<attendance_model.AttendanceResponse> getAttendances(
    String studentUuid, {
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        ApiEndpoints.getAttendances(studentUuid),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        return attendance_model.AttendanceResponse.fromJsonList(dataList);
      } else {
        throw Exception('Failed to fetch attendances with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Timetable for a student
  Future<timetable_model.TimetableResponse> getTimetable(String studentUuid) async {
    try {
      final response = await _dio.get(ApiEndpoints.getTimetable(studentUuid));

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return timetable_model.TimetableResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch timetable with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Grades for a student
  Future<grades_model.GradesResponse> getGrades(String studentUuid) async {
    try {
      final response = await _dio.get(ApiEndpoints.getGrades(studentUuid));

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        // Convert the list to the expected GradesResponse format
        return grades_model.GradesResponse.fromJsonList(dataList);
      } else {
        throw Exception('Failed to fetch grades with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Bulletins for all children
  Future<bulletins_model.BulletinsResponse> getBulletins() async {
    try {
      final response = await _dio.get(ApiEndpoints.getBulletins);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return bulletins_model.BulletinsResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch bulletins with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Periods (Semesters)
  Future<List<Period>> getPeriods() async {
    try {
      final response = await _dio.get(ApiEndpoints.getPeriods);

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        return dataList.map((e) => Period.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch periods with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Exams for a period
  Future<List<Exam>> getExams({int? periodId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (periodId != null) queryParams['period_id'] = periodId;

      final response = await _dio.get(
        ApiEndpoints.getExams,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        return dataList.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch exams with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get Bulletin (HTML/PDF) for a student in a specific period
  Future<String> getBulletinHtml({
    required String studentUuid,
    required int periodId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getBulletin(studentUuid, periodId.toString()),
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        // Check if the response indicates success or if bulletin is not available
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == false) {
            throw Exception(data['message'] ?? 'Bulletin access not enabled');
          }
        }
        return response.data.toString();
      } else {
        throw Exception('Failed to fetch bulletin with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle 403 Forbidden error (bulletin access not enabled)
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Bulletin access not enabled');
        }
        throw Exception('Bulletin access not enabled');
      }
      throw _handleDioException(e);
    }
  }

  /// Get Mini-Bulletin (Compositions) HTML for a student in a specific exam
  Future<String> getMiniBulletinHtml({
    required String studentUuid,
    required int examId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getMiniBulletin(studentUuid, examId.toString()),
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        // Check if the response indicates success or if bulletin is not available
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == false) {
            throw Exception(data['message'] ?? 'Mini-bulletin access not enabled');
          }
        }
        return response.data.toString();
      } else {
        throw Exception('Failed to fetch mini-bulletin with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle 403 Forbidden error (bulletin access not enabled)
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? data['error'] ?? 'Mini-bulletin access not enabled');
        }
        throw Exception('Mini-bulletin access not enabled');
      }
      throw _handleDioException(e);
    }
  }

  /// Gestion des exceptions Dio
  String _handleDioException(DioException e) {
    String message = 'An error occurred';

    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Server response timeout. Please try again.';
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (statusCode == 401) {
        message = 'Unauthorized. Please check your credentials.';
      } else if (statusCode == 422) {
        // Erreur de validation
        if (data is Map && data.containsKey('errors')) {
          message = (data['errors'] as Map).values.first.toString();
        } else {
          message = 'Validation error. Please check your input.';
        }
      } else if (statusCode == 404) {
        message = 'Resource not found.';
      } else if (statusCode == 500) {
        message = 'Server error. Please try again later.';
      } else {
        message = data?['message'] ?? data?['error'] ?? 'An error occurred';
      }
    } else if (e.type == DioExceptionType.unknown) {
      message = 'Network error. Please check your connection.';
    }

    return message;
  }

  /// Télécharger le bulletin PDF pour un enfant
  Future<List<int>> downloadBulletinPdf({
    required String studentUuid,
    required String periodId,
  }) async {
    try {
      final endpoint = ApiEndpoints.getBulletin(studentUuid, periodId);

      final response = await _dio.get(
        endpoint,
        options: Options(
          responseType: ResponseType.bytes,
          contentType: 'application/pdf',
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Échec du téléchargement du bulletin');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }
}


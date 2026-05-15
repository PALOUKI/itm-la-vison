import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/api_endpoints.dart';
import 'package:vision/core/services/local_storage_service.dart';
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

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});

class ApiService {
  final Ref _ref;
  late Dio _dio;
  String? _authToken;

  ApiService(this._ref) {
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

    // Interceptor pour le rafraîchissement automatique du token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          // Si on reçoit un 401 et qu'on n'est pas déjà sur l'endpoint de refresh ou de login
          if (e.response?.statusCode == 401 && 
              _authToken != null &&
              e.requestOptions.path != ApiEndpoints.refreshToken &&
              e.requestOptions.path != ApiEndpoints.login) {
            
            try {
              // Tentative de rafraîchissement du token
              final newToken = await refreshToken();
              
              // Mettre à jour les headers de la requête originale
              final options = e.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';
              
              // Relancer la requête originale
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (refreshError) {
              // Si le refresh échoue, on continue avec l'erreur originale
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Ajouter un interceptor pour les logs seulement en mode debug
    if (AppConstants.apiBaseUrl.contains('localhost') || 
        const bool.fromEnvironment('dart.vm.product') == false) {
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

  Future<T> _runWithoutAuthorization<T>(Future<T> Function() action) async {
    final previousAuthorization = _dio.options.headers['Authorization'];
    _dio.options.headers.remove('Authorization');

    try {
      return await action();
    } finally {
      if (_authToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_authToken';
      } else if (previousAuthorization != null) {
        _dio.options.headers['Authorization'] = previousAuthorization;
      }
    }
  }

  /// Login endpoint
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _runWithoutAuthorization(
        () => _dio.post(
          ApiEndpoints.login,
          data: {
            'email': email,
            'password': password,
          },
        ),
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
          
          return children_response.ChildrenResponse(children: children);
        } else if (response.data is Map<String, dynamic>) {
          return children_response.ChildrenResponse.fromJson(response.data);
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
  Future<dynamic> getMessages() async {
    try {
      final response = await _dio.get(ApiEndpoints.messages);
      if (response.statusCode == 200) {
        return response.data['data'];
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
      if (teacherId != null) data['teacher_id'] = teacherId.toString();
      if (studentId != null) data['student_id'] = studentId.toString();

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
        
        // 1. Mettre à jour en mémoire
        setAuthToken(token);
        
        // 2. Persister sur le disque pour les prochains redémarrages
        await _ref.read(localStorageServiceProvider).saveToken(token);
        
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

  /// Generic PUT request
  Future<Response<dynamic>> put(
    String path,
    dynamic data,
  ) async {
    try {
      final response = await _dio.put(path, data: data);
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
        return attendance_model.AttendanceResponse.fromJson(response.data as Map<String, dynamic>);
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
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('Failed to fetch bulletin with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
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
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        // Check if response contains JSON with availability flag instead of HTML
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          
          // Check if this is an API response with data wrapper
          if (responseMap.containsKey('data')) {
            final dataContent = responseMap['data'];
            
            if (dataContent is Map<String, dynamic>) {
              if (dataContent['available'] == false) {
                final errorMsg = responseMap['message'] ?? 'Les notes ne sont pas encore publiées';
                throw Exception(errorMsg);
              }
            }
          }
          
          // Check if success flag is false
          if (responseMap['success'] == false) {
            throw Exception(responseMap['message'] ?? 'Erreur lors de la récupération du mini-bulletin');
          }
        }
        
        // HTML content - return as string
        return response.data.toString();
      } else {
        throw Exception('Failed to fetch mini-bulletin with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Gestion des exceptions Dio
  String _handleDioException(DioException e) {
    String message = 'Une erreur est survenue.';

    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connexion trop lente. Vérifiez votre accès internet puis réessayez.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (statusCode == 401) {
        message = 'Identifiants invalides. Vérifiez vos informations de connexion.';
      } else if (statusCode == 422) {
        // Erreur de validation
        if (data is Map && data.containsKey('errors')) {
          message = (data['errors'] as Map).values.first.toString();
        } else {
          message = 'Certaines informations saisies sont invalides.';
        }
      } else if (statusCode == 404) {
        message = 'Ressource introuvable.';
      } else if (statusCode == 500) {
        message = 'Erreur serveur. Veuillez réessayer plus tard.';
      } else {
        message = data?['message'] ?? data?['error'] ?? 'Une erreur est survenue.';
      }
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      final error = e.error;

      if (error is SocketException) {
        final socketMessage = error.message.toLowerCase();

        if (socketMessage.contains('failed host lookup')) {
          message =
              'Impossible de joindre le serveur. Vérifiez votre connexion internet ou réessayez plus tard.';
        } else {
          message =
              'Aucune connexion internet détectée ou réseau instable. Vérifiez votre connexion puis réessayez.';
        }
      } else {
        message =
            'Impossible de contacter le serveur. Vérifiez votre connexion puis réessayez.';
      }
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

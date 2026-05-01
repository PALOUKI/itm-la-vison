/// Configuration centralisée des endpoints API

import 'package:vision/config/constants.dart';

class ApiEndpoints {
  // Base API URL - Utilise la constante définie dans constants.dart
  static String get baseUrl => AppConstants.apiBaseUrl;

  // ============================================
  // AUTHENTICATION ENDPOINTS
  // ============================================
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // ============================================
  // DASHBOARD
  // ============================================
  static const String dashboard = '/parent/dashboard';

  // ============================================
  // CHILDREN ENDPOINTS
  // ============================================
  static const String getChildren = '/parent/children';
  static String getChildDetails(String student) => '/parent/children/$student';
  static const String getEnrollments = '/parent/enrollments';

  // ============================================
  // ANNOUNCEMENTS ENDPOINTS
  // ============================================
  static const String announcements = '/parent/annonces';

  // ============================================
  // MESSAGES ENDPOINTS
  // ============================================
  static const String messages = '/parent/messages';
  static const String clearMessages = '/parent/messages/clear';
  static const String messageOptions = '/parent/messages/options';
  static String getChildMessageOptions(String student) => '/parent/children/$student/message-options';

  // ============================================
  // ACADEMIC / TIMETABLE
  // ============================================
  static String getTimetable(String student) => '/parent/children/$student/timetable';
  static String getGrades(String student) => '/parent/children/$student/grades';
  static const String getPeriods = '/parent/periods';
  static const String getExams = '/parent/exams';
  static const String getBulletins = '/parent/bulletins';
  static String getBulletin(String student, String period) => '/parent/children/$student/bulletins/$period';
  static String getMiniBulletin(String student, String exam) => '/parent/children/$student/mini-bulletins/$exam/render';
  static String getChildTeachers(String student) => '/parent/children/$student/teachers';
  static String getAttendances(String student) => '/parent/children/$student/attendances';

  // ============================================
  // PROFILE ENDPOINTS
  // ============================================
  static const String getProfile = '/parent/profile';
  static const String updateProfile = '/parent/profile';
  static const String updateProfilePassword = '/parent/profile/password';
  static const String updateProfilePhoto = '/parent/profile/photo';

  // ============================================
  // FINANCES ENDPOINTS
  // ============================================
  static const String getFinances = '/parent/finances';

  // ============================================
  // SUPPORT ENDPOINTS
  // ============================================
  static const String support = '/parent/support';
}


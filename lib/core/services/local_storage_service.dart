import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vision/config/constants.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  late Box<dynamic> _authBox;
  late Box<dynamic> _onboardingBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _authBox = await Hive.openBox(AppConstants.authBoxName);
    _onboardingBox = await Hive.openBox(AppConstants.onboardingBoxName);
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Onboarding Management
  Future<void> setOnboardingCompleted(bool completed) async {
    await _ensureInitialized();
    await _onboardingBox.put(AppConstants.keyOnboardingCompleted, completed);
  }

  bool hasCompletedOnboarding() {
    if (!_isInitialized) return false;
    return _onboardingBox.get(AppConstants.keyOnboardingCompleted, defaultValue: false) as bool;
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _ensureInitialized();
    await _authBox.put('auth_token', token);
  }

  String? getToken() {
    if (!_isInitialized) {
      return null;
    }
    return _authBox.get('auth_token') as String?;
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _ensureInitialized();
    await _authBox.put('user_data', userData);
  }

  Map<String, dynamic>? getUser() {
    if (!_isInitialized) {
      return null;
    }
    final data = _authBox.get('user_data');
    if (data == null) return null;
    
    try {
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _ensureInitialized();
    await _authBox.delete('auth_token');
    await _authBox.delete('user_data');
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _authBox.clear();
  }

  // Notification Preferences
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _ensureInitialized();
    await _authBox.put('push_enabled', enabled);
  }

  bool isNotificationsEnabled() {
    if (!_isInitialized) return true;
    return _authBox.get('push_enabled', defaultValue: true) as bool;
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vision/config/constants.dart';

class LocalStorageService {
  late Box<dynamic> _authBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _authBox = await Hive.openBox(AppConstants.authBoxName);
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _ensureInitialized();
    await _authBox.put('auth_token', token);
  }

  String? getToken() {
    if (!_isInitialized) {
      // Si non initialisé, retourner null pour éviter les erreurs
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
    
    // Convertir explicitement en Map<String, dynamic>
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
}

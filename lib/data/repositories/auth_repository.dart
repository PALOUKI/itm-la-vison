import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/core/services/local_storage_service.dart';
import 'package:vision/domain/models/login_response.dart';
import 'package:vision/domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);

  return AuthRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required LocalStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Connexion avec email et mot de passe
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // S'assurer que le stockage est prêt
      await _storageService.initialize();

      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // Sauvegarder le token et l'utilisateur
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user.toJson());

      // Définir le token dans le service API pour les futures requêtes
      _apiService.setAuthToken(response.token);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer l'utilisateur actuel stocké localement
  User? getCurrentUser() {
    final Map<String, dynamic>? userData = _storageService.getUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  /// Récupérer le token stocké localement
  String? getStoredToken() {
    return _storageService.getToken();
  }

  /// Vérifier si l'utilisateur est authentifié
  bool isAuthenticated() {
    return getStoredToken() != null;
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continuer même si la déconnexion échoue
    } finally {
      // Toujours nettoyer les données locales
      await _storageService.clearAuth();
      _apiService.clearAuthToken();
    }
  }

  /// Initialiser l'authentification au démarrage
  Future<void> initializeAuth() async {
    // Initialiser le stockage avant de lire le token
    await _storageService.initialize();

    final token = _storageService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
      try {
        // Fetch fresh user data
        final User user = await _apiService.getMe();
        await _storageService.saveUser(user.toJson());
        
        // S'assurer que le token actuel est bien le dernier (cas de refresh dans getMe)
        final currentToken = _apiService.getAuthToken();
        if (currentToken != null && currentToken != token) {
          await _storageService.saveToken(currentToken);
        }
      } catch (e) {
        // Continue but with local user data
      }
    }
  }

  /// Rafraîchir le token
  Future<String> refreshToken() async {
    try {
      final newToken = await _apiService.refreshToken();
      await _storageService.saveToken(newToken);
      return newToken;
    } catch (e) {
      rethrow;
    }
  }
}

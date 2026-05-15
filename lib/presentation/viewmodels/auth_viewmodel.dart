import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/core/services/local_storage_service.dart';
import 'package:vision/data/repositories/auth_repository.dart';
import 'package:vision/domain/models/user.dart';

// Auth State Provider using Notifier (Riverpod 3.x)
final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

// AuthNotifier - Manages auth state
class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _authRepository;
  bool _isInitialized = false;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    // Initialisation lors de la première utilisation
    if (!_isInitialized) {
      _isInitialized = true;
      // On lance l'initialisation asynchrone
      _initialize();
      // On retourne loading pendant qu'on vérifie le stockage
      return const AuthState.loading();
    }

    return state;
  }

  Future<void> _initialize() async {
    try {
      await _authRepository.initializeAuth();
      final user = _authRepository.getCurrentUser();

      // Si on a un utilisateur et un token, on est authentifié
      if (user != null && _authRepository.isAuthenticated()) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.initial();
      }
    } catch (e) {
      state = const AuthState.initial();
    }
  }
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow; // Re-jeter l'erreur pour la capturer dans l'UI
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const AuthState.initial();
      
      // Force la réinitialisation de tous les providers dépendants pour éviter les fuites de données
      ref.invalidateSelf();
    } catch (e) {
      state =  AuthState.error(e.toString());
    }
  }

  Future<void> initializeAuth() async {
    await _initialize();
  }


  Future<void> refreshToken() async {
    try {
      await _authRepository.refreshToken();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth State - Sealed class for type-safe state management
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.error(String message) = AuthStateError;

  bool get isLoading => this is AuthStateLoading;
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isError => this is AuthStateError;
  User? get user => this is AuthStateAuthenticated ? (this as AuthStateAuthenticated).user : null;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final User user;

  const AuthStateAuthenticated(this.user);
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);
}

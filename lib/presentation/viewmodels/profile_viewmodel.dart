import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/domain/models/user.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final profileStateProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  () => ProfileNotifier(),
);

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // On écoute l'état d'authentification. 
    // Si l'utilisateur change ou se déconnecte, ce provider se reconstruira.
    final authState = ref.watch(authStateProvider);

    if (authState.isAuthenticated && authState.user != null) {
      return ProfileState.data(authState.user!);
    } else if (authState is AuthStateLoading) {
      return const ProfileState.loading();
    } else {
      return const ProfileState.error("Utilisateur non authentifié.");
    }
  }

  Future<void> fetchProfile() async {
    // Cette méthode peut rester pour forcer un rafraîchissement si nécessaire,
    // mais le build() gère déjà la réactivité.
    ref.invalidateSelf();
  }
}

sealed class ProfileState {
  const ProfileState();

  const factory ProfileState.loading() = ProfileStateLoading;
  const factory ProfileState.data(User response) = ProfileStateData;
  const factory ProfileState.error(String message) = ProfileStateError;

  bool get isLoading => this is ProfileStateLoading;
  bool get isError => this is ProfileStateError;
  User? get dataOrNull => this is ProfileStateData ? (this as ProfileStateData).response : null;
  String? get errorOrNull => this is ProfileStateError ? (this as ProfileStateError).message : null;
}

class ProfileStateLoading extends ProfileState {
  const ProfileStateLoading();
}

class ProfileStateData extends ProfileState {
  final User response;
  const ProfileStateData(this.response);
}

class ProfileStateError extends ProfileState {
  final String message;
  const ProfileStateError(this.message);
}

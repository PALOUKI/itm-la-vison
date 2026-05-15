import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/announcements_repository.dart';
import 'package:vision/domain/models/announcement.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Announcements State Provider
final announcementsStateProvider =
    NotifierProvider<AnnouncementsNotifier, AnnouncementsState>(
  () => AnnouncementsNotifier(),
);

// Nouveau Provider auto-dispose pour forcer le rafraîchissement à chaque entrée
final announcementsListProvider = FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final repository = ref.watch(announcementsRepositoryProvider);
  final response = await repository.getParentAnnouncements();
  return response.data;
});

// AnnouncementsNotifier
class AnnouncementsNotifier extends Notifier<AnnouncementsState> {
  late AnnouncementsRepository _repository;

  @override
  AnnouncementsState build() {
    _repository = ref.watch(announcementsRepositoryProvider);
    
    // On écoute l'état d'authentification pour charger les annonces dès qu'on est connecté
    final authState = ref.watch(authStateProvider);
    
    if (authState.isAuthenticated) {
      Future.microtask(() => fetchAnnouncements());
    }
    
    return const AnnouncementsState.loading();
  }

  Future<void> fetchAnnouncements() async {
    state = const AnnouncementsState.loading();
    try {
      final response = await _repository.getParentAnnouncements();
      state = AnnouncementsState.loaded(response.data);
    } catch (e) {
      state = AnnouncementsState.error(e.toString());
    }
  }
}

// AnnouncementsState
sealed class AnnouncementsState {
  const AnnouncementsState();

  const factory AnnouncementsState.loading() = AnnouncementsStateLoading;
  const factory AnnouncementsState.loaded(List<Announcement> announcements) = AnnouncementsStateLoaded;
  const factory AnnouncementsState.error(String message) = AnnouncementsStateError;

  bool get isLoading => this is AnnouncementsStateLoading;
  bool get isLoaded => this is AnnouncementsStateLoaded;
  bool get isError => this is AnnouncementsStateError;

  List<Announcement>? get announcementsOrNull =>
      this is AnnouncementsStateLoaded ? (this as AnnouncementsStateLoaded).announcements : null;

  String? get errorOrNull =>
      this is AnnouncementsStateError ? (this as AnnouncementsStateError).message : null;

  T when<T>({
    required T Function() loading,
    required T Function(AnnouncementsStateLoaded data) data,
    required T Function(String message, StackTrace? stack) error,
  }) {
    if (this is AnnouncementsStateLoading) return loading();
    if (this is AnnouncementsStateLoaded) return data(this as AnnouncementsStateLoaded);
    if (this is AnnouncementsStateError) return error((this as AnnouncementsStateError).message, null);
    throw Exception('Unknown state: $this');
  }
}

class AnnouncementsStateLoading extends AnnouncementsState {
  const AnnouncementsStateLoading();
}

class AnnouncementsStateLoaded extends AnnouncementsState {
  final List<Announcement> announcements;

  const AnnouncementsStateLoaded(this.announcements);
}

class AnnouncementsStateError extends AnnouncementsState {
  final String message;

  const AnnouncementsStateError(this.message);
}

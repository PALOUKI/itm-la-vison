import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/messages_repository.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MessagesRepository(apiService: apiService);
});

final messagesStateProvider = NotifierProvider<MessagesNotifier, MessagesState>(
  () => MessagesNotifier(),
);

// Provider pour la liste des professeurs d'un enfant
final childTeachersProvider =
    FutureProvider.family<List<Teacher>, String>((ref, childUuid) async {
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.getChildTeachers(childUuid);
});

class MessagesNotifier extends Notifier<MessagesState> {
  late MessagesRepository _repository;

  @override
  MessagesState build() {
    _repository = ref.watch(messagesRepositoryProvider);
    Future.microtask(() => fetchMessages());
    return const MessagesState.loading();
  }

  Future<void> fetchMessages() async {
    state = const MessagesState.loading();
    try {
      final response = await _repository.getMessages();
      state = MessagesState.data(response);
    } catch (e) {
      state = MessagesState.error(e.toString());
    }
  }

  /// Envoyer un message à un professeur
  Future<void> sendToTeacher({
    required int teacherId,
    required int studentId,
    required String subject,
    required String body,
  }) async {
    await _repository.sendMessage(
      recipientType: 'teacher',
      teacherId: teacherId,
      studentId: studentId,
      subject: subject,
      body: body,
    );
    // Recharger la liste des messages après envoi
    await fetchMessages();
  }

  /// Envoyer un message à l'administration
  Future<void> sendToAdministration({
    required String subject,
    required String body,
  }) async {
    await _repository.sendMessage(
      recipientType: 'administration',
      subject: subject,
      body: body,
    );
    await fetchMessages();
  }
}

sealed class MessagesState {
  const MessagesState();

  const factory MessagesState.loading() = MessagesStateLoading;
  const factory MessagesState.data(MessagingResponse response) = MessagesStateData;
  const factory MessagesState.error(String message) = MessagesStateError;

  bool get isLoading => this is MessagesStateLoading;
  bool get isError => this is MessagesStateError;
  MessagesStateData? get dataOrNull => this is MessagesStateData ? this as MessagesStateData : null;
  String? get errorOrNull => this is MessagesStateError ? (this as MessagesStateError).message : null;
}

class MessagesStateLoading extends MessagesState {
  const MessagesStateLoading();
}

class MessagesStateData extends MessagesState {
  final MessagingResponse response;
  const MessagesStateData(this.response);
}

class MessagesStateError extends MessagesState {
  final String message;
  const MessagesStateError(this.message);
}

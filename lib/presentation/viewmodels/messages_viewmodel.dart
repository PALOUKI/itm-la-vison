import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/api_service.dart';
import 'package:vision/data/repositories/messages_repository.dart' as repo;
import 'package:vision/domain/models/message.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final messagesStateProvider = NotifierProvider<MessagesNotifier, MessagesState>(
  () => MessagesNotifier(),
);

// Provider pour la liste des professeurs d'un enfant
final childTeachersProvider =
    FutureProvider.family<List<Teacher>, String>((ref, childUuid) async {
  final repository = ref.watch(repo.messagesRepositoryProvider);
  return repository.getChildTeachers(childUuid);
});

class MessagesNotifier extends Notifier<MessagesState> {
  late final repo.MessagesRepository _repository;

  @override
  MessagesState build() {
    _repository = ref.watch(repo.messagesRepositoryProvider);
    // Fetch initial data
    Future.microtask(() => fetchMessages());
    return const MessagesStateLoading();
  }

  Future<void> fetchMessages() async {
    state = const MessagesStateLoading();
    try {
      final response = await _repository.getMessages();
      state = MessagesStateData(response);
    } catch (e) {
      state = MessagesStateError(e.toString());
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

abstract class MessagesState {
  const MessagesState();
  
  bool get isLoading => this is MessagesStateLoading;
  bool get isError => this is MessagesStateError;
  MessagingResponse? get responseOrNull => this is MessagesStateData ? (this as MessagesStateData).response : null;
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

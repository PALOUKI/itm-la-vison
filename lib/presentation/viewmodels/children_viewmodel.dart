import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/core/services/local_storage_service.dart';
import 'package:vision/data/repositories/children_repository.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/children_response.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

// Children State Provider
final childrenStateProvider =
    NotifierProvider<ChildrenNotifier, ChildrenState>(
  () => ChildrenNotifier(),
);

// Selected Child Provider
final selectedChildProvider =
    NotifierProvider<SelectedChildNotifier, Child?>(
  () => SelectedChildNotifier(),
);

class SelectedChildNotifier extends Notifier<Child?> {
  @override
  Child? build() {
    return null;
  }

  void setChild(Child? child) {
    state = child;
  }
}

// ChildrenNotifier
class ChildrenNotifier extends Notifier<ChildrenState> {
  late ChildrenRepository _repository;

  @override
  ChildrenState build() {
    _repository = ref.watch(childrenRepositoryProvider);
    return const ChildrenState.loading();
  }

  Future<void> fetchChildren() async {
    state = const ChildrenState.loading();
    try {
      final response = await _repository.getChildren();
      state = ChildrenState.loaded(response);
    } catch (e) {
      state = ChildrenState.error(e.toString());
    }
  }

  void selectChild(Child child) {
    ref.read(selectedChildProvider.notifier).setChild(child);
  }
}

// ChildrenState
sealed class ChildrenState {
  const ChildrenState();

  const factory ChildrenState.loading() = ChildrenStateLoading;
  const factory ChildrenState.loaded(ChildrenResponse data) = ChildrenStateLoaded;
  const factory ChildrenState.error(String message) = ChildrenStateError;

  bool get isLoading => this is ChildrenStateLoading;
  bool get isLoaded => this is ChildrenStateLoaded;
  bool get isError => this is ChildrenStateError;

  ChildrenResponse? get dataOrNull =>
      this is ChildrenStateLoaded ? (this as ChildrenStateLoaded).data : null;
      
  List<Child>? get childrenOrNull =>
      this is ChildrenStateLoaded ? (this as ChildrenStateLoaded).data.children : null;

  String? get errorOrNull =>
      this is ChildrenStateError ? (this as ChildrenStateError).message : null;

  T when<T>({
    required T Function() loading,
    required T Function(ChildrenResponse data) loaded,
    required T Function(String message) error,
  }) {
    if (this is ChildrenStateLoading) return loading();
    if (this is ChildrenStateLoaded) return loaded((this as ChildrenStateLoaded).data);
    if (this is ChildrenStateError) return error((this as ChildrenStateError).message);
    throw Exception('Unknown state: $this');
  }
}

class ChildrenStateLoading extends ChildrenState {
  const ChildrenStateLoading();
}

class ChildrenStateLoaded extends ChildrenState {
  final ChildrenResponse data;

  const ChildrenStateLoaded(this.data);
}

class ChildrenStateError extends ChildrenState {
  final String message;

  const ChildrenStateError(this.message);
}

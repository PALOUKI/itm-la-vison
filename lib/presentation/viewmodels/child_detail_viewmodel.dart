import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/children_repository.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/presentation/viewmodels/children_viewmodel.dart';

final childDetailProvider = NotifierProvider.family<ChildDetailNotifier, AsyncValue<Child>, String>(
  (uuid) => ChildDetailNotifier(uuid),
);

class ChildDetailNotifier extends Notifier<AsyncValue<Child>> {
  final String uuid;
  ChildDetailNotifier(this.uuid);

  late ChildrenRepository _repository;

  @override
  AsyncValue<Child> build() {
    _repository = ref.watch(childrenRepositoryProvider);
    // On lance l'initialisation
    Future.microtask(() => fetchChildDetails(uuid));
    return const AsyncValue.loading();
  }

  Future<void> fetchChildDetails(String uuid) async {
    state = const AsyncValue.loading();
    try {
      final child = await _repository.getChildDetails(uuid);
      state = AsyncValue.data(child);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider pour gérer le semestre sélectionné (S1 ou S2)
final selectedSemesterProvider = NotifierProvider<SelectedSemesterNotifier, int>(
  () => SelectedSemesterNotifier(),
);

class SelectedSemesterNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setSemester(int semester) => state = semester;
}

// Provider pour gérer quel menu est ouvert
final expandedMenuProvider = NotifierProvider<ExpandedMenuNotifier, String?>(
  () => ExpandedMenuNotifier(),
);

class ExpandedMenuNotifier extends Notifier<String?> {
  @override
  String? build() => 'Bulletins Scolaires';

  void setMenu(String? menu) => state = menu;
}

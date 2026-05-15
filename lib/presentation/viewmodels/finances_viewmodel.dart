import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/finances_repository.dart';
import 'package:vision/domain/models/finance.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

final financesStateProvider = NotifierProvider<FinancesNotifier, FinancesState>(
  () => FinancesNotifier(),
);

class FinancesNotifier extends Notifier<FinancesState> {
  late FinancesRepository _repository;

  @override
  FinancesState build() {
    _repository = ref.watch(financesRepositoryProvider);
    Future.microtask(() => fetchFinances());
    return const FinancesState.loading();
  }

  Future<void> fetchFinances() async {
    state = const FinancesState.loading();
    try {
      final response = await _repository.getFinances();
      state = FinancesState.data(response);
    } catch (e) {
      state = FinancesState.error(e.toString());
    }
  }
}

sealed class FinancesState {
  const FinancesState();

  const factory FinancesState.loading() = FinancesStateLoading;
  const factory FinancesState.data(FinancesResponse response) = FinancesStateData;
  const factory FinancesState.error(String message) = FinancesStateError;

  bool get isLoading => this is FinancesStateLoading;
  bool get isError => this is FinancesStateError;
  FinancesStateData? get dataOrNull => this is FinancesStateData ? this as FinancesStateData : null;
  String? get errorOrNull => this is FinancesStateError ? (this as FinancesStateError).message : null;
}

class FinancesStateLoading extends FinancesState {
  const FinancesStateLoading();
}

class FinancesStateData extends FinancesState {
  final FinancesResponse response;
  const FinancesStateData(this.response);
}

class FinancesStateError extends FinancesState {
  final String message;
  const FinancesStateError(this.message);
}

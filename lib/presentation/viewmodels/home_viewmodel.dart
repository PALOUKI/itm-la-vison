import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision/data/repositories/children_repository.dart';
import 'package:vision/domain/models/children_response.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

import 'package:vision/data/repositories/dashboard_repository.dart';
import 'package:vision/domain/models/dashboard_response.dart';

final homeStateProvider = NotifierProvider<HomeNotifier, HomeState>(
  () => HomeNotifier(),
);

class HomeNotifier extends Notifier<HomeState> {
  late ChildrenRepository _childrenRepository;
  late DashboardRepository _dashboardRepository;

  @override
  HomeState build() {
    _childrenRepository = ref.watch(childrenRepositoryProvider);
    _dashboardRepository = ref.watch(dashboardRepositoryProvider);
    
    // On écoute l'état d'authentification pour réagir aux changements d'utilisateur
    final authState = ref.watch(authStateProvider);
    
    if (authState.isAuthenticated) {
      // On lance le fetch dès que l'utilisateur est authentifié
      Future.microtask(() => fetchChildrenAndDashboard());
    }
    
    return const HomeState.loading();
  }

  Future<void> fetchChildrenAndDashboard() async {
    state = const HomeState.loading();
    try {
      final childrenResponse = await _childrenRepository.getChildren();
      final dashboardResponse = await _dashboardRepository.getDashboard();
      
      state = HomeState.data(childrenResponse, dashboardResponse);
    } catch (e) {
      state = HomeState.error(e.toString());
    }
  }
}

sealed class HomeState {
  const HomeState();

  const factory HomeState.loading() = HomeStateLoading;
  const factory HomeState.data(ChildrenResponse childrenResponse, DashboardResponse dashboardResponse) = HomeStateData;
  const factory HomeState.error(String message) = HomeStateError;

  bool get isLoading => this is HomeStateLoading;
  bool get isError => this is HomeStateError;
  HomeStateData? get dataOrNull => this is HomeStateData ? this as HomeStateData : null;
  String? get errorOrNull => this is HomeStateError ? (this as HomeStateError).message : null;
}

class HomeStateLoading extends HomeState {
  const HomeStateLoading();
}

class HomeStateData extends HomeState {
  final ChildrenResponse childrenResponse;
  final DashboardResponse dashboardResponse;
  const HomeStateData(this.childrenResponse, this.dashboardResponse);
}

class HomeStateError extends HomeState {
  final String message;
  const HomeStateError(this.message);
}

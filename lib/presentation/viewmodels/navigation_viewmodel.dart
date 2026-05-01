import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  () => NavigationNotifier(),
);

class NavigationNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void goToTab(int index) {
    state = index;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation tab provider
final navigationTabProvider = StateNotifierProvider<NavigationTabNotifier, int>((ref) {
  return NavigationTabNotifier();
});

class NavigationTabNotifier extends StateNotifier<int> {
  NavigationTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }
  
  void goToTranslationTab() {
    state = 0; // Translation tab is index 0
  }
}

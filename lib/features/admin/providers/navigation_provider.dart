import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final String currentRoute;
  final Map<String, dynamic> routeParams;
  final int selectedSidebarIndex;

  NavigationState({
    required this.currentRoute,
    this.routeParams = const {},
    this.selectedSidebarIndex = 0,
  });

  NavigationState copyWith({
    String? currentRoute,
    Map<String, dynamic>? routeParams,
    int? selectedSidebarIndex,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      routeParams: routeParams ?? this.routeParams,
      selectedSidebarIndex: selectedSidebarIndex ?? this.selectedSidebarIndex,
    );
  }
}

class NavigationProvider extends StateNotifier<NavigationState> {
  NavigationProvider() : super(NavigationState(currentRoute: '/admin/dashboard'));

  void navigateTo(String route, {Map<String, dynamic> params = const {}}) {
    state = state.copyWith(
      currentRoute: route,
      routeParams: params,
    );
  }

  void setSidebarIndex(int index) {
    state = state.copyWith(selectedSidebarIndex: index);
  }
}

final navigationProvider = StateNotifierProvider<NavigationProvider, NavigationState>(
      (ref) => NavigationProvider(),
);
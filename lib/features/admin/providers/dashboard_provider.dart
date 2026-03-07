import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardMetrics {
  final int totalUsers;
  final int activeUsers;
  final double monthlyRevenue;
  final int pendingRequests;
  final double waterProduction;
  final int serviceZones;

  DashboardMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.monthlyRevenue,
    required this.pendingRequests,
    required this.waterProduction,
    required this.serviceZones,
  });
}

class DashboardProvider extends StateNotifier<DashboardMetrics> {
  DashboardProvider() : super(DashboardMetrics(
    totalUsers: 0,
    activeUsers: 0,
    monthlyRevenue: 0,
    pendingRequests: 0,
    waterProduction: 0,
    serviceZones: 0,
  ));

  Future<void> loadDashboardMetrics() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    state = DashboardMetrics(
      totalUsers: 1250,
      activeUsers: 1180,
      monthlyRevenue: 1250000.00,
      pendingRequests: 23,
      waterProduction: 45000.5,
      serviceZones: 8,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardProvider, DashboardMetrics>(
      (ref) => DashboardProvider(),
);
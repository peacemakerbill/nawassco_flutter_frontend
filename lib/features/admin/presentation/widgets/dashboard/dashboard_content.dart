import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_provider.dart';
import 'welcome_header.dart';
import 'stats_grid.dart';
import 'quick_actions.dart';
import 'activity_section.dart';

class DashboardContent extends ConsumerWidget {
  final Map<String, dynamic> user;
  final Function(String) onNavigate;

  const DashboardContent({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth < 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized Welcome Header
          WelcomeHeader(user: user, isMobile: isMobile),
          SizedBox(height: isMobile ? 24 : 32),

          // Quick Stats Grid
          StatsGrid(metrics: metrics, isMobile: isMobile, isTablet: isTablet),
          SizedBox(height: isMobile ? 24 : 32),

          // Quick Actions
          QuickActionsSection(
            navigateTo: onNavigate,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          SizedBox(height: isMobile ? 24 : 32),

          // Recent Activity & Charts
          ActivitySection(isMobile: isMobile, isTablet: isTablet),
        ],
      ),
    );
  }
}
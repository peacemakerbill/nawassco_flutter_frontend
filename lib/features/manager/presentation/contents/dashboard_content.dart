import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import 'sub_widgets/dashboard/charts_row.dart';
import 'sub_widgets/dashboard/dashboard_header.dart';
import 'sub_widgets/dashboard/kpi_metrics_grid.dart';
import 'sub_widgets/dashboard/quick_actions_grid.dart';
import 'sub_widgets/dashboard/recent_alerts_list.dart';



class DashboardContent extends ConsumerWidget {
  final Function(String) onNavigate;

  const DashboardContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Fix: Access the user data using the correct field names from your User model
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final userEmail = user?['email'] ?? '';
    final profilePic = user?['profilePictureUrl'] as String?;

    // Create display name from first and last name
    final String displayName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      displayName = '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      displayName = firstName;
    } else if (lastName.isNotEmpty) {
      displayName = lastName;
    } else {
      displayName = 'Manager';
    }

    final greeting = _getTimeBasedGreeting();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header with user info
          DashboardHeader(
            firstName: firstName,
            displayName: displayName,
            greeting: greeting,
            userEmail: userEmail,
            profilePic: profilePic,
          ),
          const SizedBox(height: 24),

          // KPI Metrics
          KPIMetricsGrid(onNavigate: onNavigate),
          const SizedBox(height: 24),

          // Charts Section
          const ChartsRow(),
          const SizedBox(height: 24),

          // Quick Actions
          QuickActionsGrid(onNavigate: onNavigate),
          const SizedBox(height: 24),

          // Recent Alerts
          RecentAlertsList(onNavigate: onNavigate),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
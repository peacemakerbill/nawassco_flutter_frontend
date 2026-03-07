import 'package:flutter/material.dart';
import '../../../providers/dashboard_provider.dart';
import '../../constants/admin_colors.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  final DashboardMetrics metrics;
  final bool isMobile;
  final bool isTablet;

  const StatsGrid({
    super.key,
    required this.metrics,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 3);
    final childAspectRatio = isMobile ? 1.2 : (isTablet ? 1.1 : 1.0);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 12 : 20,
      mainAxisSpacing: isMobile ? 12 : 20,
      childAspectRatio: childAspectRatio,
      children: [
        StatCard(
          title: 'Total Users',
          value: metrics.totalUsers.toString(),
          icon: Icons.people,
          color: AdminColors.primary,
          trend: '+12%',
          isMobile: isMobile,
        ),
        StatCard(
          title: 'Monthly Revenue',
          value: 'KES ${metrics.monthlyRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: AdminColors.success,
          trend: '+8%',
          isMobile: isMobile,
        ),
        StatCard(
          title: 'Water Production',
          value: '${metrics.waterProduction.toStringAsFixed(1)} m³',
          icon: Icons.water_drop,
          color: AdminColors.info,
          trend: '+5%',
          isMobile: isMobile,
        ),
        StatCard(
          title: 'Active Users',
          value: metrics.activeUsers.toString(),
          icon: Icons.verified_user,
          color: AdminColors.success,
          trend: '+15%',
          isMobile: isMobile,
        ),
        StatCard(
          title: 'Pending Requests',
          value: metrics.pendingRequests.toString(),
          icon: Icons.pending_actions,
          color: AdminColors.warning,
          trend: '-3%',
          isMobile: isMobile,
        ),
        StatCard(
          title: 'Service Zones',
          value: metrics.serviceZones.toString(),
          icon: Icons.map,
          color: AdminColors.secondary,
          trend: 'Active',
          isMobile: isMobile,
        ),
      ],
    );
  }
}
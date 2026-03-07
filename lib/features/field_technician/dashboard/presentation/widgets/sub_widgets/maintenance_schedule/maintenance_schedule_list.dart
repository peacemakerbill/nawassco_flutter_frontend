import 'package:flutter/material.dart';

import '../../../../models/maintenance_schedule.dart';
import 'maintenance_schedule_card.dart';

class MaintenanceScheduleList extends StatelessWidget {
  final List<MaintenanceSchedule> schedules;
  final Function(MaintenanceSchedule) onScheduleTap;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const MaintenanceScheduleList({
    super.key,
    required this.schedules,
    required this.onScheduleTap,
    this.isLoading = false,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading maintenance schedules...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading schedules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Maintenance Schedules',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first maintenance schedule to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return MaintenanceScheduleCard(
            schedule: schedule,
            onTap: () => onScheduleTap(schedule),
          );
        },
      ),
    );
  }
}
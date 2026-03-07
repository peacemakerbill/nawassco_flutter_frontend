import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/employee_provider.dart';

class EmployeeStatsCard extends ConsumerWidget {
  const EmployeeStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final theme = Theme.of(context);

    // In a real app, you would get these from your backend
    final totalEmployees = employeeState.employees.length;
    final activeEmployees = employeeState.employees.where((e) => e.isActive).length;
    final onLeaveEmployees = employeeState.employees.where((e) => e.employmentStatus.toString().contains('on_leave')).length;
    final departmentsCount = employeeState.employees.map((e) => e.department).toSet().length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalEmployees.toString(), Icons.group, theme),
          _buildStatItem('Active', activeEmployees.toString(), Icons.check_circle, theme),
          _buildStatItem('On Leave', onLeaveEmployees.toString(), Icons.beach_access, theme),
          _buildStatItem('Departments', departmentsCount.toString(), Icons.category, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
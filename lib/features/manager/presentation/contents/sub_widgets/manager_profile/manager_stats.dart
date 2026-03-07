// features/managers/presentation/widgets/manager_stats.dart
import 'package:flutter/material.dart';

class ManagerStats extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const ManagerStats({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final totalManagers = stats!['totalManagers'] ?? 0;
    final activeManagers = stats!['activeManagers'] ?? 0;
    final byDepartment = stats!['byDepartment'] as Map<String, dynamic>? ?? {};
    final byManagementLevel = stats!['byManagementLevel'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manager Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Overall stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Managers',
                    value: totalManagers.toString(),
                    icon: Icons.people_alt_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Active',
                    value: activeManagers.toString(),
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Inactive',
                    value: (totalManagers - activeManagers).toString(),
                    icon: Icons.pause_circle_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Department distribution
            if (byDepartment.isNotEmpty) ...[
              const Text(
                'By Department',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: byDepartment.entries.map((entry) {
                  return _buildDistributionChip(
                    label: entry.key,
                    count: entry.value,
                    color: _getDepartmentColor(entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            // Level distribution
            if (byManagementLevel.isNotEmpty) ...[
              const Text(
                'By Management Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: byManagementLevel.entries.map((entry) {
                  return _buildDistributionChip(
                    label: entry.key,
                    count: entry.value,
                    color: _getLevelColor(entry.key),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChip({
    required String label,
    required dynamic count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_formatLabel(label)}: $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    return label.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'executive':
        return Colors.purple;
      case 'finance':
        return Colors.blue;
      case 'operations':
        return Colors.green;
      case 'human_resources':
        return Colors.orange;
      case 'sales_marketing':
        return Colors.red;
      case 'it':
        return Colors.indigo;
      case 'procurement':
        return Colors.teal;
      case 'customer_service':
        return Colors.amber;
      case 'technical_services':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'c_suite':
        return Colors.purple;
      case 'executive':
        return Colors.indigo;
      case 'senior_management':
        return Colors.blue;
      case 'middle_management':
        return Colors.green;
      case 'first_line_management':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
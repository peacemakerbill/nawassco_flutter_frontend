import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/employee_model.dart';
import '../../../../../providers/employee_provider.dart';

class EmployeeQuickActions extends ConsumerWidget {
  final Employee employee;
  final String id;
  final WidgetRef ref;

  const EmployeeQuickActions({
    super.key,
    required this.employee,
    required this.id,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final provider = widgetRef.read(employeeProvider.notifier);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(
          icon: Icons.email,
          label: 'Send Email',
          color: Colors.blue,
          onTap: () {
            // Send email logic
          },
        ),
        _buildActionButton(
          icon: Icons.chat,
          label: 'Message',
          color: Colors.green,
          onTap: () {
            // Send message logic
          },
        ),
        _buildActionButton(
          icon: Icons.calendar_today,
          label: 'Schedule',
          color: Colors.orange,
          onTap: () {
            // Schedule meeting logic
          },
        ),
        if (provider.canManageEmployees)
          _buildActionButton(
            icon: Icons.edit,
            label: 'Edit',
            color: Colors.purple,
            onTap: () {
              // Navigate to edit screen
            },
          ),
        if (provider.canManageEmployees)
          _buildActionButton(
            icon: Icons.document_scanner,
            label: 'Documents',
            color: Colors.brown,
            onTap: () {
              // View documents
            },
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
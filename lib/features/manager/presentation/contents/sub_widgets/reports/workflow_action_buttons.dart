import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/reports/management_report_model.dart';
import '../../../../providers/management_report_provider.dart';

class WorkflowActionButtons extends ConsumerWidget {
  final ManagementReport report;

  const WorkflowActionButtons({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (report.isEditable)
                ActionButton(
                  label: 'Edit',
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () {
                    // Show edit dialog
                  },
                ),
              if (report.isEditable)
                ActionButton(
                  label: 'Submit for Review',
                  icon: Icons.send,
                  color: Colors.green,
                  onPressed: () {
                    _showConfirmationDialog(
                      context,
                      'Submit for Review',
                      'Are you sure you want to submit this report for review?',
                      () => ref
                          .read(managementReportProvider.notifier)
                          .submitForReview(report.id),
                    );
                  },
                ),
              if (report.isUnderReview)
                ActionButton(
                  label: 'Approve',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  onPressed: () {
                    _showConfirmationDialog(
                      context,
                      'Approve Report',
                      'Are you sure you want to approve this report?',
                      () => ref
                          .read(managementReportProvider.notifier)
                          .approveReport(report.id),
                    );
                  },
                ),
              if (report.isApproved)
                ActionButton(
                  label: 'Publish',
                  icon: Icons.public,
                  color: Colors.purple,
                  onPressed: () {
                    _showConfirmationDialog(
                      context,
                      'Publish Report',
                      'Are you sure you want to publish this report?',
                      () => ref
                          .read(managementReportProvider.notifier)
                          .publishReport(report.id),
                    );
                  },
                ),
              if (report.isPublished)
                ActionButton(
                  label: 'Download',
                  icon: Icons.download,
                  color: Colors.blue,
                  onPressed: () {
                    // Download report
                  },
                ),
              ActionButton(
                label: 'Share',
                icon: Icons.share,
                color: Colors.grey.shade600,
                onPressed: () {
                  // Share report
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../models/field_service_report_model.dart';

class BulkActionsBar extends StatelessWidget {
  final int selectedCount;
  final List<FieldServiceReport> selectedReports;
  final Function() onBulkApprove;
  final Function() onBulkReject;
  final Function() onExportSelected;
  final Function() onClearSelection;

  const BulkActionsBar({
    super.key,
    required this.selectedCount,
    required this.selectedReports,
    required this.onBulkApprove,
    required this.onBulkReject,
    required this.onExportSelected,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          Text(
            '$selectedCount reports selected',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const Spacer(),

          // Bulk Approve
          if (selectedReports.any((r) => r.canApprove))
            OutlinedButton.icon(
              onPressed: onBulkApprove,
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Approve Selected'),
            ),

          const SizedBox(width: 8),

          // Bulk Reject
          if (selectedReports.any((r) => r.canApprove))
            OutlinedButton.icon(
              onPressed: onBulkReject,
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Reject Selected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),

          const SizedBox(width: 8),

          // Export Selected
          OutlinedButton.icon(
            onPressed: onExportSelected,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export Selected'),
          ),

          const SizedBox(width: 8),

          // Clear Selection
          TextButton(
            onPressed: onClearSelection,
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }
}

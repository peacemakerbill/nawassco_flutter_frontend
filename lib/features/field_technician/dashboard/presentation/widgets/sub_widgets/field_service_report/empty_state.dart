import 'package:flutter/material.dart';

class ManagementEmptyState extends StatelessWidget {
  final String selectedView;
  final bool showCreateButton;
  final Function()? onCreateReport;

  const ManagementEmptyState({
    super.key,
    required this.selectedView,
    this.showCreateButton = false,
    this.onCreateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptySubtitle(),
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          if (showCreateButton && onCreateReport != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateReport,
              icon: const Icon(Icons.add),
              label: const Text('Create Report'),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    return switch (selectedView) {
      'pending' => 'No pending reports for approval',
      'recent' => 'No recent reports found',
      _ => 'No reports found',
    };
  }

  String _getEmptySubtitle() {
    return switch (selectedView) {
      'pending' => 'All reports have been processed',
      _ => 'Try adjusting your filters',
    };
  }
}
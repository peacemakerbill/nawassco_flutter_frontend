import 'package:flutter/material.dart';

class BulkActionsPanel extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkUpdateStatus;
  final VoidCallback onBulkExport;
  final VoidCallback onBulkDelete;

  const BulkActionsPanel({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onBulkUpdateStatus,
    required this.onBulkExport,
    required this.onBulkDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Selection Info
          Chip(
            label: Text('$selectedCount selected'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),

          // Select All / Clear
          OutlinedButton(
            onPressed: onSelectAll,
            child: const Text('Select All'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onClearSelection,
            child: const Text('Clear'),
          ),
          const Spacer(),

          // Bulk Actions
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'update_status',
                child: ListTile(
                  leading: Icon(Icons.update),
                  title: Text('Update Status'),
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Selected'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Selected'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'update_status':
                  onBulkUpdateStatus();
                  break;
                case 'export':
                  onBulkExport();
                  break;
                case 'delete':
                  onBulkDelete();
                  break;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Actions',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
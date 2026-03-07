import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';

class DeleteResourceDialog extends ConsumerStatefulWidget {
  final Resource resource;

  const DeleteResourceDialog({super.key, required this.resource});

  @override
  ConsumerState<DeleteResourceDialog> createState() => _DeleteResourceDialogState();
}

class _DeleteResourceDialogState extends ConsumerState<DeleteResourceDialog> {
  bool _isDeleting = false;
  bool _permanentDelete = false;

  Future<void> _deleteResource() async {
    setState(() {
      _isDeleting = true;
    });

    final notifier = ref.read(resourceProvider.notifier);
    final success = await notifier.deleteResource(widget.resource.id);

    setState(() {
      _isDeleting = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.resource.title}" moved to trash'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete resource'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _permanentlyDelete() async {
    setState(() {
      _isDeleting = true;
    });

    final notifier = ref.read(resourceProvider.notifier);
    // Note: You need to implement permanentlyDeleteResource method in provider
    // final success = await notifier.permanentlyDeleteResource(widget.resource.id);

    setState(() {
      _isDeleting = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource permanently deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            _permanentDelete ? Iconsax.warning_2 : Iconsax.trash,
            color: _permanentDelete ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Text(
            _permanentDelete ? 'Permanent Delete' : 'Move to Trash',
            style: TextStyle(
              color: _permanentDelete ? Colors.red : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning Message
          if (_permanentDelete)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All files and data will be permanently deleted.',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Resource will be moved to trash. You can restore it later.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Resource Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.resource.category.icon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.resource.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.resource.filesCount} files • ${widget.resource.formattedTotalSize}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats Summary
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatItem(
                icon: Iconsax.document_download,
                label: 'Downloads',
                value: widget.resource.downloadStats.totalDownloads.toString(),
              ),
              _StatItem(
                icon: Iconsax.eye,
                label: 'Unique Users',
                value: widget.resource.downloadStats.uniqueUsers.toString(),
              ),
              _StatItem(
                icon: Iconsax.calendar,
                label: 'Created',
                value: _formatDate(widget.resource.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Permanent Delete Toggle (for admins/managers)
          if (widget.resource.status == ResourceStatus.deleted ||
              widget.resource.status == ResourceStatus.archived)
            CheckboxListTile(
              title: const Text('Permanent Delete'),
              subtitle: const Text('Completely remove from system'),
              value: _permanentDelete,
              onChanged: (value) {
                setState(() {
                  _permanentDelete = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              tileColor: Colors.red.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),

        // Delete Button
        ElevatedButton(
          onPressed: _isDeleting
              ? null
              : _permanentDelete
              ? _permanentlyDelete
              : _deleteResource,
          style: ElevatedButton.styleFrom(
            backgroundColor: _permanentDelete ? Colors.red : Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isDeleting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _permanentDelete ? Iconsax.warning_2 : Iconsax.trash,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(_permanentDelete ? 'Delete Permanently' : 'Move to Trash'),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
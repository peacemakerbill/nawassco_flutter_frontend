import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';// Add this import
import 'package:intl/intl.dart';
import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../../models/job_model.dart';
import 'job_detail_card.dart';

class JobCard extends ConsumerWidget { // Change to ConsumerWidget
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final bool showActions;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPublish,
    this.onClose,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef parameter
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final authState = ref.watch(authProvider); // Use ref.watch instead of context.read

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: job.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => JobDetailCard(job: job),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.jobNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isSmallScreen) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: job.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: job.statusColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        job.statusDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: job.statusColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.business,
                    label: job.department,
                    color: Colors.blue,
                  ),
                  _buildInfoChip(
                    icon: Icons.location_on,
                    label: job.location,
                    color: Colors.green,
                  ),
                  _buildInfoChip(
                    icon: Icons.work,
                    label: job.jobType.displayName,
                    color: Colors.orange,
                  ),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: job.workMode.displayName,
                    color: Colors.purple,
                  ),
                  if (job.isRemoteFriendly)
                    _buildInfoChip(
                      icon: Icons.home,
                      label: 'Remote Friendly',
                      color: Colors.teal,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salary Range',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.salaryRange.displayText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Deadline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(job.applicationDeadline),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: job.isExpired ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.people,
                        value: job.numberOfOpenings.toString(),
                        label: 'Openings',
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        icon: Icons.description,
                        value: job.numberOfApplications.toString(),
                        label: 'Applications',
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        icon: Icons.remove_red_eye,
                        value: job.views.toString(),
                        label: 'Views',
                      ),
                    ],
                  ),
                  if (showActions && (onEdit != null || onDelete != null))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => _buildPopupMenuItems(context, authState), // Pass authState
                      onSelected: (value) => _handleMenuSelection(value, context),
                    ),
                ],
              ),
              if (isSmallScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: job.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      job.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: job.statusColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  List<PopupMenuItem<String>> _buildPopupMenuItems(BuildContext context, AuthState authState) {
    final items = <PopupMenuItem<String>>[];

    // Use the passed authState parameter instead of reading from context

    if (authState.hasAnyRole(['HR', 'Admin', 'Manager'])) {
      if (job.status == JobStatus.DRAFT && onPublish != null) {
        items.add(
          const PopupMenuItem<String>(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish, size: 18),
                SizedBox(width: 8),
                Text('Publish'),
              ],
            ),
          ),
        );
      }

      if (job.status == JobStatus.PUBLISHED && onClose != null) {
        items.add(
          const PopupMenuItem<String>(
            value: 'close',
            child: Row(
              children: [
                Icon(Icons.close, size: 18),
                SizedBox(width: 8),
                Text('Close'),
              ],
            ),
          ),
        );
      }

      if (onEdit != null) {
        items.add(
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        );
      }

      if (onDelete != null) {
        items.add(
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      }
    }

    return items;
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'publish':
        onPublish?.call();
        break;
      case 'close':
        onClose?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';

class WorkOrderCard extends StatelessWidget {
  final WorkOrder workOrder;
  final VoidCallback onTap;
  final Function(WorkOrderStatus) onStatusChange;

  const WorkOrderCard({
    super.key,
    required this.workOrder,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = workOrder.isOverdue;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(workOrder.priority),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workOrder.workOrderNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workOrder.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(workOrder.status, isOverdue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(workOrder.status, isOverdue).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(workOrder.status, isOverdue),
                          size: 14,
                          color: _getStatusColor(workOrder.status, isOverdue),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOverdue ? 'OVERDUE' : workOrder.status.displayName.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(workOrder.status, isOverdue),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                workOrder.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 400;

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 8,
                      childAspectRatio: isWide ? 3 : 2.5,
                    ),
                    children: [
                      _buildDetailItem(
                        Icons.person,
                        'Customer',
                        workOrder.customerName,
                      ),
                      _buildDetailItem(
                        Icons.location_on,
                        'Location',
                        workOrder.location.city,
                      ),
                      _buildDetailItem(
                        Icons.assignment,
                        'Type',
                        workOrder.type.displayName,
                      ),
                      _buildDetailItem(
                        Icons.calendar_today,
                        'Scheduled',
                        dateFormat.format(workOrder.scheduledDate),
                      ),
                      _buildDetailItem(
                        Icons.access_time,
                        'Duration',
                        '${workOrder.estimatedDuration} min',
                      ),
                      _buildDetailItem(
                        Icons.people,
                        'Assigned',
                        workOrder.assignedTechnicianNames.isNotEmpty
                            ? '${workOrder.assignedTechnicianNames.length} techs'
                            : 'Unassigned',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${workOrder.progress}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: workOrder.progress / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getProgressColor(workOrder.progress),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workOrder.tasks.where((t) => t.status == TaskStatus.completed).length}'
                        ' of ${workOrder.tasks.length} tasks completed',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLocationOptions(context);
                      },
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Navigate'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showContactOptions(context);
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Contact'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _handleStatusAction(context);
                      },
                      icon: Icon(
                        _getActionButtonIcon(workOrder.status),
                        size: 16,
                      ),
                      label: Text(_getActionButtonText(workOrder.status)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: _getActionButtonColor(workOrder.status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(WorkOrderPriority priority) {
    return switch (priority) {
      WorkOrderPriority.low => Colors.green,
      WorkOrderPriority.medium => Colors.orange,
      WorkOrderPriority.high => Colors.red,
      WorkOrderPriority.urgent => Colors.purple,
    };
  }

  Color _getStatusColor(WorkOrderStatus status, bool isOverdue) {
    if (isOverdue) return Colors.red;

    return switch (status) {
      WorkOrderStatus.pending => Colors.orange,
      WorkOrderStatus.scheduled => Colors.blue,
      WorkOrderStatus.inProgress => Colors.blueAccent,
      WorkOrderStatus.onHold => Colors.purple,
      WorkOrderStatus.completed => Colors.green,
      WorkOrderStatus.cancelled => Colors.grey,
      WorkOrderStatus.failed => Colors.red,
    };
  }

  IconData _getStatusIcon(WorkOrderStatus status, bool isOverdue) {
    if (isOverdue) return Icons.warning;

    return switch (status) {
      WorkOrderStatus.pending => Icons.pending,
      WorkOrderStatus.scheduled => Icons.schedule,
      WorkOrderStatus.inProgress => Icons.play_arrow,
      WorkOrderStatus.onHold => Icons.pause,
      WorkOrderStatus.completed => Icons.check_circle,
      WorkOrderStatus.cancelled => Icons.cancel,
      WorkOrderStatus.failed => Icons.error,
    };
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  IconData _getActionButtonIcon(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Icons.play_arrow,
      WorkOrderStatus.scheduled => Icons.play_arrow,
      WorkOrderStatus.inProgress => Icons.check,
      WorkOrderStatus.onHold => Icons.play_arrow,
      WorkOrderStatus.completed => Icons.visibility,
      WorkOrderStatus.cancelled => Icons.refresh,
      WorkOrderStatus.failed => Icons.refresh,
    };
  }

  String _getActionButtonText(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => 'Start',
      WorkOrderStatus.scheduled => 'Start',
      WorkOrderStatus.inProgress => 'Complete',
      WorkOrderStatus.onHold => 'Resume',
      WorkOrderStatus.completed => 'View',
      WorkOrderStatus.cancelled => 'Reopen',
      WorkOrderStatus.failed => 'Retry',
    };
  }

  Color _getActionButtonColor(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.pending => Colors.blue,
      WorkOrderStatus.scheduled => Colors.blue,
      WorkOrderStatus.inProgress => Colors.green,
      WorkOrderStatus.onHold => Colors.orange,
      WorkOrderStatus.completed => Colors.grey,
      WorkOrderStatus.cancelled => Colors.blue,
      WorkOrderStatus.failed => Colors.blue,
    };
  }

  void _handleStatusAction(BuildContext context) {
    switch (workOrder.status) {
      case WorkOrderStatus.pending:
      case WorkOrderStatus.scheduled:
        onStatusChange(WorkOrderStatus.inProgress);
        break;
      case WorkOrderStatus.inProgress:
        _showCompletionDialog(context);
        break;
      case WorkOrderStatus.onHold:
        onStatusChange(WorkOrderStatus.inProgress);
        break;
      case WorkOrderStatus.completed:
        onTap();
        break;
      case WorkOrderStatus.cancelled:
      case WorkOrderStatus.failed:
        onStatusChange(WorkOrderStatus.pending);
        break;
    }
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Work Order'),
        content: const Text('Are you sure you want to mark this work order as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusChange(WorkOrderStatus.completed);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showLocationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Open in Maps'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions),
              title: const Text('Get Directions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_location),
              title: const Text('Share Location'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Customer'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send SMS'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
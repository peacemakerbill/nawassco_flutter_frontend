import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class OutageCard extends StatelessWidget {
  final Outage outage;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final Function(OutageStatus)? onUpdateStatus;
  final bool showActions;

  const OutageCard({
    super.key,
    required this.outage,
    this.onTap,
    this.onEdit,
    this.onUpdateStatus,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                outage.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showActions) _buildActionMenu(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${outage.outageNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  _buildDetailItem(
                    Icons.location_on,
                    outage.affectedAreas.isNotEmpty
                        ? outage.affectedAreas.first.zone
                        : 'Unknown Zone',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.timer,
                    '${outage.estimatedDuration ~/ 60}h ${outage.estimatedDuration % 60}m',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.people,
                    '${outage.estimatedAffectedCustomers} affected',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress and Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityBadge(),
                  _buildProgressIndicator(),
                ],
              ),

              // Timeline (if in progress)
              if (outage.status == OutageStatus.IN_PROGRESS)
                const SizedBox(height: 12),
              if (outage.status == OutageStatus.IN_PROGRESS)
                _buildTimeline(),

              // Last Update
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatTimeDifference(outage.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (!showActions)
                    Text(
                      _getStatusText(outage.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(outage.status),
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

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getStatusColor(outage.status),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<OutageStatus>(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (context) {
        return OutageStatus.values.map((status) {
          return PopupMenuItem(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_getStatusText(status)),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (status) {
        if (onUpdateStatus != null) {
          onUpdateStatus!(status);
        }
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(outage.priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getPriorityColor(outage.priority).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        outage.priority.toString().split('.').last,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getPriorityColor(outage.priority),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${_getProgressPercentage(outage.status)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 4,
          child: LinearProgressIndicator(
            value: _getProgressPercentage(outage.status) / 100,
            backgroundColor: Colors.grey[200],
            color: _getStatusColor(outage.status),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Est. End',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.5, // Calculate actual progress
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OutageStatus status) {
    switch (status) {
      case OutageStatus.REPORTED:
        return Colors.orange;
      case OutageStatus.CONFIRMED:
        return Colors.deepOrange;
      case OutageStatus.IN_PROGRESS:
        return Colors.blue;
      case OutageStatus.ON_HOLD:
        return Colors.amber;
      case OutageStatus.RESOLVED:
        return Colors.green;
      case OutageStatus.VERIFIED:
        return Colors.teal;
      case OutageStatus.CLOSED:
        return Colors.grey;
      case OutageStatus.CANCELLED:
        return Colors.red;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.LOW:
        return Colors.green;
      case PriorityLevel.MEDIUM:
        return Colors.blue;
      case PriorityLevel.HIGH:
        return Colors.orange;
      case PriorityLevel.CRITICAL:
        return Colors.red;
    }
  }

  String _getStatusText(OutageStatus status) {
    return status.toString().split('.').last.replaceAll('_', ' ');
  }

  int _getProgressPercentage(OutageStatus status) {
    switch (status) {
      case OutageStatus.REPORTED:
        return 10;
      case OutageStatus.CONFIRMED:
        return 25;
      case OutageStatus.IN_PROGRESS:
        return 50;
      case OutageStatus.ON_HOLD:
        return 30;
      case OutageStatus.RESOLVED:
        return 90;
      case OutageStatus.VERIFIED:
        return 95;
      case OutageStatus.CLOSED:
        return 100;
      case OutageStatus.CANCELLED:
        return 0;
    }
  }

  String _formatTimeDifference(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
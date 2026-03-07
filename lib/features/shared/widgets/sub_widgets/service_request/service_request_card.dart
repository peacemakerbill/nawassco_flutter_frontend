import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/service_request_model.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;
  final VoidCallback? onAssign;
  final VoidCallback? onUpdateStatus;
  final bool showActions;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.onAssign,
    this.onUpdateStatus,
    this.showActions = false,
  });

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.completed:
      case RequestStatus.closed:
        return Colors.green;
      case RequestStatus.inProgress:
      case RequestStatus.scheduled:
        return Colors.blue;
      case RequestStatus.submitted:
      case RequestStatus.underReview:
        return Colors.orange;
      case RequestStatus.rejected:
      case RequestStatus.cancelled:
        return Colors.red;
      case RequestStatus.onHold:
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
        return Colors.red[900]!;
      case PriorityLevel.urgent:
        return Colors.red;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
      case PriorityLevel.urgent:
        return Icons.warning;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.medium:
        return Icons.horizontal_rule;
      case PriorityLevel.low:
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
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
                          request.requestNumber,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.serviceName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Chip(
                        label: Text(
                          request.status.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _getStatusColor(request.status),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getPriorityIcon(request.priority),
                            size: 16,
                            color: _getPriorityColor(request.priority),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(request.priority),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.customerName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    request.customerPhone,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Requested: ${dateFormat.format(request.requestedDate)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (request.assignedToName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.engineering, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assigned to: ${request.assignedToName}',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: request.progress / 100,
                backgroundColor: Colors.grey[200],
                color: _getStatusColor(request.status),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${request.progress}% Complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'KES ${request.estimatedCost.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              if (showActions &&
                  (onAssign != null || onUpdateStatus != null)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onAssign != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Assign'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    if (onAssign != null && onUpdateStatus != null)
                      const SizedBox(width: 8),
                    if (onUpdateStatus != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUpdateStatus,
                          icon: const Icon(Icons.update, size: 16),
                          label: const Text('Update Status'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

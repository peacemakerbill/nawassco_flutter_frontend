import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../../models/service_request_model.dart';

class ServiceRequestDetails extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onEdit;
  final VoidCallback? onAssign;
  final VoidCallback? onUpdateStatus;
  final VoidCallback? onAddNote;
  final bool showActions;

  const ServiceRequestDetails({
    super.key,
    required this.request,
    this.onEdit,
    this.onAssign,
    this.onUpdateStatus,
    this.onAddNote,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with request number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requestNumber,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      request.serviceName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  request.status.name.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: _getStatusColor(request.status),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${request.progress}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: request.progress / 100,
                backgroundColor: Colors.grey[200],
                color: _getStatusColor(request.status),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Customer Information Card
          _buildDetailCard(
            title: 'Customer Information',
            icon: Icons.person,
            children: [
              _buildDetailRow('Name', request.customerName),
              _buildDetailRow('Email', request.customerEmail),
              _buildDetailRow('Phone', request.customerPhone),
              _buildDetailRow('Address', request.customerAddress),
              _buildDetailRow('Customer Type', request.customerType.name.replaceAll('_', ' ').toTitleCase()),
              _buildDetailRow('Property Type', request.propertyType.name.replaceAll('_', ' ').toTitleCase()),
            ],
          ),
          const SizedBox(height: 16),

          // Service Details Card
          _buildDetailCard(
            title: 'Service Details',
            icon: Icons.build,
            children: [
              _buildDetailRow('Service Code', request.serviceCode),
              _buildDetailRow('Service Category', request.serviceCategory.name.replaceAll('_', ' ').toTitleCase()),
              _buildDetailRow('Service Type', request.serviceType.name.replaceAll('_', ' ').toTitleCase()),
              _buildDetailRow('Description', request.description),
              _buildDetailRow('Priority', request.priority.name.replaceAll('_', ' ').toTitleCase()),
              _buildDetailRow('Department', request.department),
            ],
          ),
          const SizedBox(height: 16),

          // Location Details Card
          _buildDetailCard(
            title: 'Location Details',
            icon: Icons.location_on,
            children: [
              _buildDetailRow('Address', request.location.address),
              _buildDetailRow('Zone', request.location.zone),
              _buildDetailRow('Subzone', request.location.subzone),
              if (request.location.landmark != null)
                _buildDetailRow('Landmark', request.location.landmark!),
              _buildDetailRow('Accessibility', request.location.accessibility),
            ],
          ),
          const SizedBox(height: 16),

          // Scheduling Card
          _buildDetailCard(
            title: 'Scheduling',
            icon: Icons.calendar_today,
            children: [
              _buildDetailRow('Requested Date', dateFormat.format(request.requestedDate)),
              if (request.preferredDate != null)
                _buildDetailRow('Preferred Date', dateFormat.format(request.preferredDate!)),
              if (request.scheduledDate != null)
                _buildDetailRow('Scheduled Date', dateFormat.format(request.scheduledDate!)),
              if (request.estimatedCompletion != null)
                _buildDetailRow('Estimated Completion', dateFormat.format(request.estimatedCompletion!)),
              if (request.actualStart != null)
                _buildDetailRow('Actual Start', dateFormat.format(request.actualStart!)),
              if (request.actualCompletion != null)
                _buildDetailRow('Actual Completion', dateFormat.format(request.actualCompletion!)),
            ],
          ),
          const SizedBox(height: 16),

          // Assignment Card
          if (request.assignedTo != null) ...[
            _buildDetailCard(
              title: 'Assignment',
              icon: Icons.engineering,
              children: [
                _buildDetailRow('Assigned To', request.assignedToName ?? 'Technician'),
                if (request.assignedTeam != null)
                  _buildDetailRow('Team', request.assignedTeam!),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Costing Card
          _buildDetailCard(
            title: 'Costing & Billing',
            icon: Icons.attach_money,
            children: [
              _buildDetailRow('Estimated Cost', 'KES ${request.estimatedCost.toStringAsFixed(2)}'),
              if (request.actualCost != null)
                _buildDetailRow('Actual Cost', 'KES ${request.actualCost!.toStringAsFixed(2)}'),
              _buildDetailRow('Payment Status', request.paymentStatus.name.replaceAll('_', ' ').toTitleCase()),
              if (request.invoiceNumber != null)
                _buildDetailRow('Invoice Number', request.invoiceNumber!),
            ],
          ),
          const SizedBox(height: 16),

          // SLA Tracking Card
          _buildDetailCard(
            title: 'SLA Tracking',
            icon: Icons.timer,
            children: [
              _buildDetailRow('SLA Status', request.slaStatus.name.replaceAll('_', ' ').toTitleCase()),
              if (request.responseTime != null)
                _buildDetailRow('Response Time', '${request.responseTime!.toStringAsFixed(1)} hours'),
              if (request.resolutionTime != null)
                _buildDetailRow('Resolution Time', '${request.resolutionTime!.toStringAsFixed(1)} hours'),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          if (showActions && (onEdit != null || onAssign != null || onUpdateStatus != null))
            Column(
              children: [
                Row(
                  children: [
                    if (onEdit != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (onEdit != null && onAssign != null) const SizedBox(width: 12),
                    if (onAssign != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Assign'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                if (onUpdateStatus != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onUpdateStatus,
                      icon: const Icon(Icons.update),
                      label: const Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (onAddNote != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAddNote,
                      icon: const Icon(Icons.note_add),
                      label: const Text('Add Note'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context as BuildContext).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context as BuildContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

extension StringExtension on String {
  String toTitleCase() {
    return split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/employee_model.dart';

class DocumentCard extends StatelessWidget {
  final EmployeeDocument document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(document.status);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDocumentIcon(document.documentType),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  document.documentType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded: ${dateFormat.format(document.uploadDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              document.status.toString().split('.').last,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'contract':
        return Icons.assignment;
      case 'identification':
        return Icons.badge;
      case 'qualification':
        return Icons.school;
      case 'certification':
        return Icons.verified;
      case 'payroll':
        return Icons.monetization_on;
      case 'performance':
        return Icons.assessment;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
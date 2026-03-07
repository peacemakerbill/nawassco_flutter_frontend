import 'package:flutter/material.dart';
import '../../../../../../models/applicant/document_model.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrimary;
  final bool showActions;

  const DocumentCard({
    super.key,
    required this.document,
    this.onDownload,
    this.onDelete,
    this.onSetPrimary,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getDocumentIcon(document.type);
    final color = _getDocumentColor(document.type);
    final fileSize = _formatFileSize(document.fileSize);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              document.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (document.isPrimary)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green, width: 0.5),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDocumentTypeName(document.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'download' && onDownload != null) {
                        onDownload!();
                      } else if (value == 'set_primary' &&
                          onSetPrimary != null) {
                        onSetPrimary!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onDownload != null)
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download, size: 18),
                              SizedBox(width: 8),
                              Text('Download'),
                            ],
                          ),
                        ),
                      if (onSetPrimary != null && !document.isPrimary)
                        const PopupMenuItem(
                          value: 'set_primary',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 18, color: Colors.amber),
                              SizedBox(width: 8),
                              Text('Set as Primary'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(document.uploadDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.storage,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (document.description != null &&
                document.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                document.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'resume':
        return Icons.description;
      case 'cover_letter':
        return Icons.mail;
      case 'portfolio':
        return Icons.business_center;
      case 'transcript':
        return Icons.school;
      case 'certificate':
        return Icons.verified;
      case 'id':
        return Icons.badge;
      case 'degree':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type) {
      case 'resume':
        return Colors.blue;
      case 'cover_letter':
        return Colors.green;
      case 'portfolio':
        return Colors.purple;
      case 'transcript':
        return Colors.orange;
      case 'certificate':
        return Colors.teal;
      case 'id':
        return Colors.red;
      case 'degree':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getDocumentTypeName(String type) {
    switch (type) {
      case 'resume':
        return 'Resume';
      case 'cover_letter':
        return 'Cover Letter';
      case 'portfolio':
        return 'Portfolio';
      case 'transcript':
        return 'Transcript';
      case 'certificate':
        return 'Certificate';
      case 'id':
        return 'ID Document';
      case 'degree':
        return 'Degree';
      default:
        return 'Document';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

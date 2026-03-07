import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../../../../../models/applicant/document_model.dart';

class DocumentsListWidget extends StatelessWidget {
  final List<DocumentModel> documents;
  final bool isLoading;
  final VoidCallback onUpload;
  final Function(DocumentModel) onDelete;

  const DocumentsListWidget({
    super.key,
    required this.documents,
    required this.isLoading,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: documents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Documents Added',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your documents like resume, certificates, and portfolio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Document'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          return _buildDocumentCard(context, document);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onUpload,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.upload, color: Colors.white),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel document) {
    final icon = _getDocumentIcon(document.type);
    final color = _getDocumentColor(document.type);
    final fileSize = _formatFileSize(document.fileSize);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
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
                          Text(
                            document.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (document.isPrimary)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green, width: 0.5),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDocumentTypeName(document.type),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'download') {
                      _downloadDocument(document);
                    } else if (value == 'delete') {
                      onDelete(document);
                    } else if (value == 'set_primary' && !document.isPrimary) {
                      // Handle set as primary
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                    ),
                    if (!document.isPrimary && document.type == 'resume')
                      const PopupMenuItem(
                        value: 'set_primary',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Set as Primary'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
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
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(document.uploadDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.storage,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (document.description != null && document.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  document.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
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
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _downloadDocument(DocumentModel document) {
    // This would typically open the document URL
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document.name}...'),
      ),
    );
  }
}
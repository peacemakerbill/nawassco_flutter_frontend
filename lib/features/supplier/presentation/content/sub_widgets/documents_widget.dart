import 'package:flutter/material.dart';

import '../../../models/supplier_model.dart';

class DocumentsWidget extends StatefulWidget {
  final Supplier? supplier;
  final VoidCallback onUpload;

  const DocumentsWidget({
    super.key,
    required this.supplier,
    required this.onUpload,
  });

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends State<DocumentsWidget> {
  final List<Map<String, dynamic>> _documents = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    // Mock documents - in real app, fetch from API
    setState(() {
      _documents.addAll([
        {
          'id': '1',
          'name': 'Business Registration Certificate',
          'type': 'registration',
          'uploadDate': DateTime.now().subtract(const Duration(days: 30)),
          'expiryDate': DateTime.now().add(const Duration(days: 335)),
          'status': 'verified',
          'url': 'https://example.com/doc1.pdf',
        },
        {
          'id': '2',
          'name': 'Tax Compliance Certificate',
          'type': 'tax',
          'uploadDate': DateTime.now().subtract(const Duration(days: 15)),
          'expiryDate': DateTime.now().add(const Duration(days: 180)),
          'status': 'pending',
          'url': 'https://example.com/doc2.pdf',
        },
        {
          'id': '3',
          'name': 'Quality Management System Certificate',
          'type': 'quality',
          'uploadDate': DateTime.now().subtract(const Duration(days: 60)),
          'expiryDate': DateTime.now().add(const Duration(days: 300)),
          'status': 'verified',
          'url': 'https://example.com/doc3.pdf',
        },
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Upload Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upload, color: Color(0xFF0066A1)),
                      SizedBox(width: 8),
                      Text(
                        'Upload Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload required documents for verification. Supported formats: PDF, DOC, DOCX, JPG, PNG',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isUploading ? null : _selectFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Select File'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadDocument,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066A1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Documents List
          if (_documents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No documents uploaded',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your business documents to complete your profile',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._documents.map((doc) => _buildDocumentCard(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Document Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getDocumentColor(document['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDocumentIcon(document['type']),
                color: _getDocumentColor(document['type']),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Document Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploaded: ${_formatDate(document['uploadDate'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (document['expiryDate'] != null)
                    Text(
                      'Expires: ${_formatDate(document['expiryDate'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getExpiryColor(document['expiryDate']),
                      ),
                    ),
                ],
              ),
            ),

            // Status & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(document['status']),
                const SizedBox(height: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('View'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: ListTile(
                        leading: Icon(Icons.download),
                        title: Text('Download'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'replace',
                      child: ListTile(
                        leading: Icon(Icons.swap_horiz),
                        title: Text('Replace'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _viewDocument(document);
                        break;
                      case 'download':
                        _downloadDocument(document);
                        break;
                      case 'replace':
                        _replaceDocument(document);
                        break;
                      case 'delete':
                        _deleteDocument(document);
                        break;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'verified': Colors.green,
      'pending': Colors.orange,
      'rejected': Colors.red,
      'expired': Colors.grey,
    };

    final color = statusColors[status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'registration':
        return Icons.business;
      case 'tax':
        return Icons.receipt;
      case 'quality':
        return Icons.verified;
      case 'license':
        return Icons.card_membership;
      default:
        return Icons.description;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type) {
      case 'registration':
        return Colors.blue;
      case 'tax':
        return Colors.green;
      case 'quality':
        return Colors.orange;
      case 'license':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiry < 0) return Colors.red;
    if (daysUntilExpiry < 30) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectFile() {
    // Implement file selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select File'),
        content: const Text('File selection would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _uploadDocument() {
    setState(() {
      _isUploading = true;
    });

    // Simulate upload
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
      widget.onUpload();
    });
  }

  void _viewDocument(Map<String, dynamic> document) {
    // Implement document viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${document['name']}')),
    );
  }

  void _downloadDocument(Map<String, dynamic> document) {
    // Implement document download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${document['name']}')),
    );
  }

  void _replaceDocument(Map<String, dynamic> document) {
    // Implement document replacement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Replacing ${document['name']}')),
    );
  }

  void _deleteDocument(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete ${document['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _documents.remove(document);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${document['name']} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
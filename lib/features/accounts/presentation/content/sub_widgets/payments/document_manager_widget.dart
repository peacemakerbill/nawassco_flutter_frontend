import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';
import 'document_viewer_widget.dart';

class DocumentManagerWidget extends ConsumerStatefulWidget {
  final String paymentId;
  final List<PaymentDocument> documents;

  const DocumentManagerWidget({
    super.key,
    required this.paymentId,
    required this.documents,
  });

  @override
  ConsumerState<DocumentManagerWidget> createState() =>
      _DocumentManagerWidgetState();
}

class _DocumentManagerWidgetState extends ConsumerState<DocumentManagerWidget> {
  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.attach_file,
                    color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Payment Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.documents.isNotEmpty)
                  Text(
                    '${widget.documents.length} file${widget.documents.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Button
            if (paymentState.isUploadingDocument)
              const LinearProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _uploadDocument,
                  icon: const Icon(Icons.upload, size: 20),
                  label: const Text('Upload Document'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Documents List
            if (widget.documents.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No documents attached',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload supporting documents for this payment',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: widget.documents
                    .map((document) => _buildDocumentItem(document))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(PaymentDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: document.fileColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              document.fileIcon,
              color: document.fileColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.originalName ?? document.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${document.fileSizeFormatted} • ${_formatDate(document.uploadedAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) => _handleDocumentAction(value, document),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20),
                    SizedBox(width: 8),
                    Text('View'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument() async {
    // Store context locally to ensure it's available for snackbars
    final currentContext = context;

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // Images
          'pdf', // PDF
          'doc', 'docx', // Word
          'xls', 'xlsx', // Excel
          'ppt', 'pptx', // PowerPoint
          'txt', // Text
        ],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final notifier = ref.read(paymentProvider.notifier);
        int uploadedCount = 0;

        for (final file in result.files) {
          if (file.path != null) {
            final success =
            await notifier.uploadPaymentDocument(widget.paymentId, file);
            if (success) {
              uploadedCount++;

              // Show individual success message
              Future.microtask(() {
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text('Uploaded ${file.name}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
            }
          }
        }

        // Show summary message if multiple files uploaded
        if (uploadedCount > 1 && mounted) {
          Future.microtask(() {
            if (mounted) {
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(
                  content: Text('Successfully uploaded $uploadedCount files'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          });
        }
      } else {
        // User cancelled or no files selected
        print('File selection cancelled or no files selected');
      }
    } catch (e) {
      print('File picker error: $e');

      // Show error message
      Future.microtask(() {
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text('Failed to upload document: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void _handleDocumentAction(String action, PaymentDocument document) async {
    final currentContext = context;
    final notifier = ref.read(paymentProvider.notifier);

    switch (action) {
      case 'view':
        _viewDocument(document);
        break;
      case 'download':
        final success = await notifier.downloadPaymentDocument(document);
        if (success) {
          Future.microtask(() {
            if (mounted) {
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(
                  content: Text(
                      'Downloaded ${document.originalName ?? document.fileName}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
        }
        break;
      case 'delete':
        _deleteDocument(document);
        break;
    }
  }

  void _viewDocument(PaymentDocument document) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerWidget(
        document: document,
        documents: widget.documents,
        initialIndex: widget.documents.indexOf(document),
      ),
    );
  }

  Future<void> _deleteDocument(PaymentDocument document) async {
    final currentContext = context;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${document.originalName ?? document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(paymentProvider.notifier);
      final success =
      await notifier.deletePaymentDocument(widget.paymentId, document.id);
      if (success) {
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content:
                Text('Deleted ${document.originalName ?? document.fileName}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payment_provider.dart';

class DocumentViewerWidget extends ConsumerStatefulWidget {
  final PaymentDocument document;
  final List<PaymentDocument> documents;
  final int initialIndex;

  const DocumentViewerWidget({
    super.key,
    required this.document,
    required this.documents,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<DocumentViewerWidget> createState() =>
      _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends ConsumerState<DocumentViewerWidget> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentDocument = widget.documents[_currentIndex];

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Icon(currentDocument.fileIcon,
                      color: currentDocument.fileColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDocument.originalName ??
                              currentDocument.fileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${currentDocument.fileSizeFormatted} • ${_formatDate(currentDocument.uploadedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.documents.length > 1) ...[
                    IconButton(
                      onPressed: _currentIndex > 0 ? _previousDocument : null,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous',
                    ),
                    Text(
                      '${_currentIndex + 1}/${widget.documents.length}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: _currentIndex < widget.documents.length - 1
                          ? _nextDocument
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next',
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: () => _downloadDocument(currentDocument),
                    icon: const Icon(Icons.download),
                    tooltip: 'Download',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Document Content
            Expanded(
              child: widget.documents.length > 1
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: widget.documents.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildDocumentContent(widget.documents[index]);
                      },
                    )
                  : _buildDocumentContent(currentDocument),
            ),

            // Thumbnails for multiple documents
            if (widget.documents.length > 1) ...[
              const Divider(height: 1),
              Container(
                height: 80,
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.documents.length,
                  itemBuilder: (context, index) {
                    final doc = widget.documents[index];
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index
                                ? const Color(0xFF0D47A1)
                                : Colors.grey[300]!,
                            width: _currentIndex == index ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildThumbnail(doc),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent(PaymentDocument document) {
    if (document.isImage) {
      return PhotoView(
        imageProvider: CachedNetworkImageProvider(document.url),
        backgroundDecoration: const BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      );
    } else if (document.isPdf) {
      return SfPdfViewer.network(document.url);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              document.fileIcon,
              size: 64,
              color: document.fileColor,
            ),
            const SizedBox(height: 16),
            Text(
              document.originalName ?? document.fileName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${document.fileSizeFormatted} • ${document.fileType.toUpperCase()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _downloadDocument(document),
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openInBrowser(document),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in Browser'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildThumbnail(PaymentDocument document) {
    if (document.isImage) {
      return CachedNetworkImage(
        imageUrl: document.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        color: document.fileColor.withOpacity(0.1),
        child: Center(
          child: Icon(
            document.fileIcon,
            color: document.fileColor,
            size: 24,
          ),
        ),
      );
    }
  }

  void _previousDocument() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextDocument() {
    if (_currentIndex < widget.documents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _downloadDocument(PaymentDocument document) async {
    final notifier = ref.read(paymentProvider.notifier);
    final success = await notifier.downloadPaymentDocument(document);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Downloaded ${document.originalName ?? document.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openInBrowser(PaymentDocument document) async {
    final uri = Uri.parse(document.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open document in browser'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

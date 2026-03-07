import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class DocumentViewerDialog extends StatefulWidget {
  final String documentUrl;

  const DocumentViewerDialog({super.key, required this.documentUrl});

  @override
  State<DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  late bool _isImage;
  late bool _isVideo;
  late bool _isPdf;
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _determineFileType();
    if (_isVideo) {
      _initializeVideoPlayer();
    }
  }

  void _determineFileType() {
    final url = widget.documentUrl.toLowerCase();
    _isImage = url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.gif');
    _isVideo = url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
    _isPdf = url.endsWith('.pdf');
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.network(widget.documentUrl);
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      showControls: true,
    );
    setState(() {});
  }

  Future<void> _downloadDocument() async {
    final uri = Uri.parse(widget.documentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open document'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isImage ? Icons.image_rounded :
                    _isVideo ? Icons.video_library_rounded :
                    _isPdf ? Icons.picture_as_pdf_rounded :
                    Icons.insert_drive_file_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Document Viewer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _downloadDocument,
                    icon: const Icon(Icons.download_rounded),
                    tooltip: 'Download',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContentView(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(ThemeData theme) {
    if (_isImage) {
      return InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Image.network(
            widget.documentUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    } else if (_isVideo && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    } else if (_isPdf) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'PDF Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This document can be downloaded and viewed externally',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadDocument,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download PDF'),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_rounded, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This document can be downloaded and viewed externally',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _downloadDocument,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Document'),
          ),
        ],
      );
    }
  }
}
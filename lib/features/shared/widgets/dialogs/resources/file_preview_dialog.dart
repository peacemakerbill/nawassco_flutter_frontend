import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';
import '../../../utils/resources/file_utils.dart';

class FilePreviewDialog extends ConsumerStatefulWidget {
  final Resource resource;
  final ResourceFile file;
  final int fileIndex;

  const FilePreviewDialog({
    super.key,
    required this.resource,
    required this.file,
    required this.fileIndex,
  });

  @override
  ConsumerState<FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends ConsumerState<FilePreviewDialog> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration? _audioDuration;
  Duration? _audioPosition;
  bool _isLoading = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    if (widget.file.isVideo) {
      _videoController = VideoPlayerController.network(widget.file.fileUrl);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      setState(() {
        _isLoading = false;
      });
    } else if (widget.file.isAudio) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onDurationChanged.listen((duration) {
        setState(() {
          _audioDuration = duration;
        });
      });
      _audioPlayer!.onPositionChanged.listen((position) {
        setState(() {
          _audioPosition = position;
        });
      });
      _audioPlayer!.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _audioPosition = Duration.zero;
        });
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePlayPause() {
    if (widget.file.isVideo) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    } else if (widget.file.isAudio) {
      if (_isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.play(UrlSource(widget.file.fileUrl));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  void _seekAudio(double value) {
    if (_audioDuration != null) {
      final position = Duration(milliseconds: (value * _audioDuration!.inMilliseconds).round());
      _audioPlayer!.seek(position);
    }
  }

  Future<void> _downloadFile() async {
    final notifier = ref.read(resourceProvider.notifier);
    await notifier.downloadFile(
      resourceId: widget.resource.id,
      fileIndex: widget.fileIndex,
      fileName: widget.file.fileName,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${widget.file.fileName}...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isFullscreen ? 0 : 20),
      ),
      child: Column(
        children: [
          // Header
          if (!_isFullscreen)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.file.isImage
                        ? Iconsax.gallery
                        : widget.file.isPdf
                        ? Iconsax.document_text
                        : widget.file.isVideo
                        ? Iconsax.video
                        : widget.file.isAudio
                        ? Iconsax.music
                        : Iconsax.document,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.file.fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.file.formattedSize} • ${FileUtils.getFileTypeDescription(widget.file.mimeType)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                  ),
                ],
              ),
            ),

          // Content Area
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (widget.file.isImage)
                  _buildImageViewer()
                else if (widget.file.isPdf)
                    _buildPdfViewer()
                  else if (widget.file.isVideo)
                      _buildVideoPlayer()
                    else if (widget.file.isAudio)
                        _buildAudioPlayer()
                      else
                        _buildUnsupportedView(),

                // Fullscreen toggle button
                if (!widget.file.isPdf)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isFullscreen = !_isFullscreen;
                        });
                      },
                      icon: Icon(
                        _isFullscreen ? Icons.minimize : Iconsax.maximize,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Controls
          if (!_isFullscreen)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.resource.files.length > 1)
                          Text(
                            'File ${widget.fileIndex + 1} of ${widget.resource.files.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        if (widget.file.description != null)
                          Text(
                            widget.file.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      if (widget.file.isVideo || widget.file.isAudio)
                        IconButton(
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            _isPlaying ? Iconsax.pause : Iconsax.play,
                            color: Colors.blue,
                          ),
                          tooltip: _isPlaying ? 'Pause' : 'Play',
                        ),
                      IconButton(
                        onPressed: _downloadFile,
                        icon: const Icon(Iconsax.document_download, color: Colors.green),
                        tooltip: 'Download',
                      ),
                      if (widget.resource.files.length > 1)
                        IconButton(
                          onPressed: () {
                            // Show file list
                          },
                          icon: const Icon(Iconsax.document, color: Colors.purple),
                          tooltip: 'Show all files',
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return PhotoView(
      imageProvider: NetworkImage(widget.file.fileUrl),
      backgroundDecoration: BoxDecoration(color: Colors.black),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.file.id),
      loadingBuilder: (context, event) => Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      ),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.gallery_remove, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _initializeMedia();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.network(
      widget.file.fileUrl,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      scrollDirection: PdfScrollDirection.vertical,
      pageSpacing: 2,
      onDocumentLoaded: (details) {
        setState(() {
          _isLoading = false;
        });
      },
      onDocumentLoadFailed: (details) {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_videoController!),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Iconsax.pause_circle : Iconsax.play_circle,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black54,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
            ),
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _isPlaying ? Iconsax.pause_circle : Iconsax.play_circle,
                size: 80,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Slider(
                  value: (_audioPosition?.inMilliseconds ?? 0) /
                      (_audioDuration?.inMilliseconds ?? 1),
                  onChanged: _seekAudio,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_audioPosition ?? Duration.zero),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _formatDuration(_audioDuration ?? Duration.zero),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.document, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Preview not available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This file type cannot be previewed in the app',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadFile,
            icon: const Icon(Iconsax.document_download),
            label: const Text('Download to View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
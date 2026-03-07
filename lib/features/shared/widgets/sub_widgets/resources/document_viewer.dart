import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';

class DocumentViewer extends ConsumerStatefulWidget {
  final Resource resource;
  final int fileIndex;

  const DocumentViewer({
    super.key,
    required this.resource,
    required this.fileIndex,
  });

  @override
  ConsumerState<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends ConsumerState<DocumentViewer> {
  late ResourceFile _file;
  PdfViewerController? _pdfController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration? _audioDuration;
  Duration? _audioPosition;
  bool _isLoading = true;
  bool _isFullscreen = false;
  double _currentPage = 1;
  double _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _file = widget.resource.files[widget.fileIndex];
    _initializeViewer();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _initializeViewer() async {
    if (_file.isPdf) {
      _pdfController = PdfViewerController();
      setState(() {
        _isLoading = false;
      });
    } else if (_file.isVideo) {
      _videoController = VideoPlayerController.network(_file.fileUrl);
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Colors.grey[200]!,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } else if (_file.isAudio) {
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
    if (_file.isVideo) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    } else if (_file.isAudio) {
      if (_isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.play(UrlSource(_file.fileUrl));
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
      fileName: _file.fileName,
    );
  }

  void _goToPage(int page) {
    if (_pdfController != null) {
      _pdfController!.jumpToPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          _file.fileName,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_file.isPdf)
            IconButton(
              onPressed: () => _showPageDialog(),
              icon: const Icon(Iconsax.document),
              tooltip: 'Go to Page',
            ),
          IconButton(
            onPressed: _downloadFile,
            icon: const Icon(Iconsax.document_download),
            tooltip: 'Download',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFullscreen = !_isFullscreen;
              });
            },
            icon: Icon(_isFullscreen ? Icons.minimize : Iconsax.maximize),
            tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: _isFullscreen ? null : _buildControls(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_file.isImage) {
      return PhotoView(
        imageProvider: NetworkImage(_file.fileUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        heroAttributes: PhotoViewHeroAttributes(tag: _file.id),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      );
    } else if (_file.isPdf) {
      return SfPdfViewer.network(
        _file.fileUrl,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        scrollDirection: PdfScrollDirection.vertical,
        pageSpacing: 2,
        onDocumentLoaded: (details) {
          setState(() {
            _totalPages = details.document.pages.count.toDouble();
          });
        },
        onPageChanged: (details) {
          setState(() {
            _currentPage = details.newPageNumber.toDouble();
          });
        },
      );
    } else if (_file.isVideo) {
      return Chewie(controller: _chewieController!);
    } else if (_file.isAudio) {
      return _buildAudioPlayer();
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.document, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Preview not available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This file type cannot be previewed',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 30),
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
              color: Colors.blue.withAlpha(30),
              border: Border.all(color: Colors.blue.withAlpha(100), width: 2),
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
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  _file.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Slider(
                  value: (_audioPosition?.inMilliseconds ?? 0) /
                      (_audioDuration?.inMilliseconds ?? 1),
                  onChanged: _seekAudio,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (_file.isPdf) {
      return Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              onPressed: _currentPage > 1 ? () => _goToPage((_currentPage - 1).toInt()) : null,
              icon: Icon(
                Iconsax.arrow_left_2,
                color: _currentPage > 1 ? Colors.white : Colors.grey,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _currentPage,
                    min: 1,
                    max: _totalPages,
                    onChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                      _goToPage(value.toInt());
                    },
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                  Text(
                    'Page ${_currentPage.toInt()} of ${_totalPages.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _currentPage < _totalPages ? () => _goToPage((_currentPage + 1).toInt()) : null,
              icon: Icon(
                Iconsax.arrow_right_3,
                color: _currentPage < _totalPages ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else if (_file.isAudio) {
      return Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _isPlaying ? Iconsax.pause : Iconsax.play,
                color: Colors.white,
                size: 28,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: (_audioPosition?.inMilliseconds ?? 0) /
                        (_audioDuration?.inMilliseconds ?? 1),
                    onChanged: _seekAudio,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
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
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _downloadFile,
              icon: const Icon(Iconsax.document_download, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showPageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Go to Page'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Page number (1-${_totalPages.toInt()})',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final page = int.tryParse(value) ?? 1;
            if (page >= 1 && page <= _totalPages) {
              _goToPage(page);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle go to page
              Navigator.pop(context);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
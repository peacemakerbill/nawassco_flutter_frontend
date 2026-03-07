import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/resources/file_utils.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String fileName;
  final double progress;
  final int? downloadSpeed;
  final int? timeRemaining;
  final bool isCompleted;
  final bool isFailed;
  final String? errorMessage;

  const DownloadProgressDialog({
    super.key,
    required this.fileName,
    required this.progress,
    this.downloadSpeed,
    this.timeRemaining,
    this.isCompleted = false,
    this.isFailed = false,
    this.errorMessage,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.isCompleted
                      ? Iconsax.tick_circle
                      : widget.isFailed
                      ? Iconsax.close_circle
                      : Iconsax.document_download,
                  color: widget.isCompleted
                      ? Colors.green
                      : widget.isFailed
                      ? Colors.red
                      : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isCompleted
                      ? 'Download Complete'
                      : widget.isFailed
                      ? 'Download Failed'
                      : 'Downloading',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (!widget.isCompleted && !widget.isFailed)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                    iconSize: 24,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // File Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        FileUtils.getFileIcon(widget.fileName),
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (widget.downloadSpeed != null)
                          Text(
                            'Speed: ${FileUtils.formatBytes(widget.downloadSpeed!)}/s',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (widget.isFailed)
            // Error State
              Column(
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.errorMessage ?? 'Download failed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            else if (widget.isCompleted)
            // Success State
              Column(
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    size: 64,
                    color: Colors.green.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'File downloaded successfully!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.fileName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
            // Progress State
              Column(
                children: [
                  // Circular Progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: widget.progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(widget.progress),
                          ),
                        ),
                      ),
                      Text(
                        '${(widget.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Linear Progress
                  LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: Colors.grey[200],
                    color: _getProgressColor(widget.progress),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 12),

                  // Progress Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(widget.progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      if (widget.timeRemaining != null)
                        Text(
                          _formatTimeRemaining(widget.timeRemaining!),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Speed Info
                  if (widget.downloadSpeed != null)
                    Text(
                      'Speed: ${FileUtils.formatBytes(widget.downloadSpeed!)}/s',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 32),

            // Actions
            if (widget.isCompleted || widget.isFailed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isCompleted ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.isCompleted ? 'Open File' : 'Try Again'),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Pause/Resume functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.pause, size: 18),
                          SizedBox(width: 8),
                          Text('Pause'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _formatTimeRemaining(int seconds) {
    if (seconds < 60) return '$seconds seconds';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')} minutes';
  }
}
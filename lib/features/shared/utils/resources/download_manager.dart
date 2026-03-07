import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' hide File;
import 'file_utils.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio();
  final Map<String, DownloadTask> _tasks = {};
  final List<DownloadListener> _listeners = [];

  Future<String?> downloadFile({
    required String url,
    required String fileName,
    Map<String, String>? headers,
    String? savePath,
    void Function(double progress)? onProgress,
    void Function(String? path)? onComplete,
    void Function(String error)? onError,
  }) async {
    final taskId = '${DateTime.now().millisecondsSinceEpoch}_${fileName.hashCode}';

    // Request storage permission for mobile
    if (!kIsWeb) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        onError?.call('Storage permission denied');
        return null;
      }
    }

    final task = DownloadTask(
      id: taskId,
      url: url,
      fileName: fileName,
      status: DownloadStatus.downloading,
      progress: 0.0,
      startTime: DateTime.now(),
    );

    _tasks[taskId] = task;
    _notifyListeners(task);

    try {
      String finalPath;

      if (kIsWeb) {
        // For web, use blob download
        final response = await _dio.get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: headers,
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = received / total;
              task.progress = progress;
              task.status = DownloadStatus.downloading;
              _notifyListeners(task);
              onProgress?.call(progress);
            }
          },
        );

        final bytes = response.data as List<int>;
        final blob = Blob([bytes]);
        final blobUrl = Url.createObjectUrlFromBlob(blob);

        final anchor = AnchorElement(href: blobUrl)
          ..setAttribute('download', fileName)
          ..click();

        Url.revokeObjectUrl(blobUrl);

        task.status = DownloadStatus.completed;
        task.progress = 1.0;
        task.endTime = DateTime.now();
        _notifyListeners(task);

        onComplete?.call(fileName);
        return fileName;
      } else {
        // For mobile, save to downloads directory
        final directory = savePath != null
            ? Directory(savePath)
            : await getDownloadsDirectory();

        if (directory == null) {
          throw Exception('Downloads directory not found');
        }

        final file = File('${directory.path}/$fileName');
        final tempFile = File('${directory.path}/$fileName.temp');

        await _dio.download(
          url,
          tempFile.path,
          options: Options(headers: headers),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = received / total;
              task.progress = progress;
              task.status = DownloadStatus.downloading;
              _notifyListeners(task);
              onProgress?.call(progress);
            }
          },
        );

        // Rename temp file to final file
        await tempFile.rename(file.path);

        task.status = DownloadStatus.completed;
        task.progress = 1.0;
        task.endTime = DateTime.now();
        task.filePath = file.path;
        _notifyListeners(task);

        onComplete?.call(file.path);
        return file.path;
      }
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      task.endTime = DateTime.now();
      _notifyListeners(task);

      onError?.call(e.toString());
      return null;
    }
  }

  Future<void> cancelDownload(String taskId) async {
    final task = _tasks[taskId];
    if (task != null && task.status == DownloadStatus.downloading) {
      // Cancel the Dio request if possible
      // Note: Dio doesn't have built-in cancellation for downloads
      task.status = DownloadStatus.cancelled;
      task.endTime = DateTime.now();
      _notifyListeners(task);
    }
  }

  Future<bool> deleteDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<DownloadTask>> getDownloadHistory() async {
    return _tasks.values.toList();
  }

  void addListener(DownloadListener listener) {
    _listeners.add(listener);
  }

  void removeListener(DownloadListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(DownloadTask task) {
    for (final listener in _listeners) {
      listener.onDownloadUpdate(task);
    }
  }

  static String formatDownloadSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) return '$bytesPerSecond B/s';
    if (bytesPerSecond < 1048576) return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / 1048576).toStringAsFixed(1)} MB/s';
  }

  static String formatTimeRemaining(int bytesRemaining, int bytesPerSecond) {
    if (bytesPerSecond == 0) return '--:--';

    final seconds = bytesRemaining ~/ bytesPerSecond;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes % 60}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds % 60}s';
    } else {
      return '${seconds}s';
    }
  }
}

enum DownloadStatus {
  downloading,
  completed,
  failed,
  cancelled,
  paused,
}

class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  DownloadStatus status;
  double progress;
  final DateTime startTime;
  DateTime? endTime;
  String? filePath;
  String? error;
  int? fileSize;
  int? downloadedBytes;
  int? speedBytesPerSecond;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.status,
    required this.progress,
    required this.startTime,
    this.endTime,
    this.filePath,
    this.error,
    this.fileSize,
    this.downloadedBytes,
    this.speedBytesPerSecond,
  });

  Duration get duration => endTime?.difference(startTime) ?? Duration.zero;

  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    return FileUtils.formatBytes(fileSize!);
  }

  String get formattedDownloadedBytes {
    if (downloadedBytes == null) return '0 B';
    return FileUtils.formatBytes(downloadedBytes!);
  }

  String get formattedSpeed {
    if (speedBytesPerSecond == null) return '0 B/s';
    return DownloadManager.formatDownloadSpeed(speedBytesPerSecond!);
  }

  String get formattedTimeRemaining {
    if (speedBytesPerSecond == null || fileSize == null || downloadedBytes == null) {
      return '--:--';
    }
    final remaining = fileSize! - downloadedBytes!;
    return DownloadManager.formatTimeRemaining(remaining, speedBytesPerSecond!);
  }
}

abstract class DownloadListener {
  void onDownloadUpdate(DownloadTask task);
}
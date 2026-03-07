import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FileUtils {
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static IconData getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
    // Images
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
        return Iconsax.gallery;

    // PDF
      case 'pdf':
        return Iconsax.document_text;

    // Word Documents
      case 'doc':
      case 'docx':
        return Iconsax.document;

    // Excel
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Iconsax.document_text;

    // PowerPoint
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;

    // Videos
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return Iconsax.video;

    // Audio
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
      case 'm4a':
        return Iconsax.music;

    // Archives
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Iconsax.archive;

    // Text files
      case 'txt':
      case 'rtf':
      case 'md':
        return Iconsax.document_text;

    // Code files
      case 'js':
      case 'ts':
      case 'dart':
      case 'java':
      case 'cpp':
      case 'c':
      case 'py':
      case 'html':
      case 'css':
      case 'json':
      case 'xml':
        return Iconsax.code;

      default:
        return Iconsax.document;
    }
  }

  static String getFileTypeDescription(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return 'Image File';
    } else if (mimeType == 'application/pdf') {
      return 'PDF Document';
    } else if (mimeType.startsWith('video/')) {
      return 'Video File';
    } else if (mimeType.startsWith('audio/')) {
      return 'Audio File';
    } else if (mimeType.contains('word') || mimeType.contains('officedocument.word')) {
      return 'Word Document';
    } else if (mimeType.contains('excel') || mimeType.contains('officedocument.spreadsheet')) {
      return 'Excel Spreadsheet';
    } else if (mimeType.contains('powerpoint') || mimeType.contains('officedocument.presentation')) {
      return 'PowerPoint Presentation';
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return 'Compressed Archive';
    } else if (mimeType.contains('text/')) {
      return 'Text File';
    }
    return 'Document';
  }

  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
      'ico', 'tiff', 'tif', 'heic', 'heif'
    ].contains(extension);
  }

  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm',
      'm4v', 'mpg', 'mpeg', '3gp', 'ogv'
    ].contains(extension);
  }

  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a',
      'wma', 'aiff', 'alac', 'opus'
    ].contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
      'txt', 'rtf', 'md', 'odt', 'ods', 'odp'
    ].contains(extension);
  }

  static bool isArchiveFile(String fileName) {
    final extension = getFileExtension(fileName);
    return [
      'zip', 'rar', '7z', 'tar', 'gz', 'bz2',
      'xz', 'lz', 'lzma', 'z', 'tgz'
    ].contains(extension);
  }

  static String getSafeFileName(String fileName) {
    // Remove invalid characters and limit length
    var safeName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    if (safeName.length > 100) {
      final extension = getFileExtension(safeName);
      final nameWithoutExt = safeName.substring(0, safeName.length - extension.length - 1);
      safeName = '${nameWithoutExt.substring(0, 95)}...$extension';
    }
    return safeName;
  }

  static Future<String> getFileChecksum(File file) async {
    // Simple checksum calculation (in production, use proper hash)
    final bytes = await file.readAsBytes();
    var checksum = 0;
    for (var byte in bytes) {
      checksum = (checksum + byte) & 0xFFFFFFFF;
    }
    return checksum.toRadixString(16).padLeft(8, '0');
  }
}
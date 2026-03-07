import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/resource_model.dart';


class FileTypeIcons {
  static IconData getIconForType(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Iconsax.document_text;
      case ResourceType.image:
        return Iconsax.gallery;
      case ResourceType.video:
        return Iconsax.video;
      case ResourceType.audio:
        return Iconsax.music;
      case ResourceType.archive:
        return Iconsax.archive;
      case ResourceType.other:
        return Iconsax.document;
    }
  }

  static IconData getIconForResource(Resource resource) {
    return getIconForType(resource.resourceType);
  }

  static IconData getIconForFileExtension(String extension) {
    final ext = extension.toLowerCase();

    // Images
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Iconsax.gallery;
    }

    // PDF
    if (ext == 'pdf') {
      return Iconsax.document_text;
    }

    // Documents
    if (['doc', 'docx'].contains(ext)) {
      return Iconsax.document;
    }

    // Spreadsheets
    if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return Iconsax.document_text;
    }

    // Presentations
    if (['ppt', 'pptx'].contains(ext)) {
      return Icons.slideshow;
    }

    // Videos
    if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'].contains(ext)) {
      return Iconsax.video;
    }

    // Audio
    if (['mp3', 'wav', 'aac', 'flac', 'ogg'].contains(ext)) {
      return Iconsax.music;
    }

    // Archives
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return Iconsax.archive;
    }

    // Text files
    if (['txt', 'rtf', 'md'].contains(ext)) {
      return Iconsax.document_text;
    }

    // Code files
    if (['js', 'ts', 'dart', 'java', 'cpp', 'c', 'py', 'html', 'css', 'json', 'xml'].contains(ext)) {
      return Iconsax.code;
    }

    return Iconsax.document;
  }

  static Color getColorForType(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Colors.blue;
      case ResourceType.image:
        return Colors.green;
      case ResourceType.video:
        return Colors.purple;
      case ResourceType.audio:
        return Colors.orange;
      case ResourceType.archive:
        return Colors.red;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  static String getMimeTypeIcon(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return 'image';
    } else if (mimeType == 'application/pdf') {
      return 'pdf';
    } else if (mimeType.startsWith('video/')) {
      return 'video';
    } else if (mimeType.startsWith('audio/')) {
      return 'audio';
    } else if (mimeType.contains('word') || mimeType.contains('officedocument.word')) {
      return 'word';
    } else if (mimeType.contains('excel') || mimeType.contains('officedocument.spreadsheet')) {
      return 'excel';
    } else if (mimeType.contains('powerpoint') || mimeType.contains('officedocument.presentation')) {
      return 'powerpoint';
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return 'archive';
    } else if (mimeType.contains('text/')) {
      return 'text';
    }
    return 'document';
  }
}
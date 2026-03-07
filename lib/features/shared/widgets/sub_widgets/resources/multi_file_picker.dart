import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';

import '../../../models/resource_model.dart';
import '../../../utils/resources/file_type_icons.dart';
import '../../../utils/resources/file_utils.dart';

class MultiFilePicker extends StatefulWidget {
  final List<PlatformFile> selectedFiles;
  final ResourceType resourceType;
  final int primaryFileIndex;
  final VoidCallback onPickFiles;
  final Function(int) onRemoveFile;
  final Function(int) onSetPrimaryFile;
  final Function(List<PlatformFile>)? onAddFiles;

  const MultiFilePicker({
    super.key,
    required this.selectedFiles,
    required this.resourceType,
    required this.primaryFileIndex,
    required this.onPickFiles,
    required this.onRemoveFile,
    required this.onSetPrimaryFile,
    this.onAddFiles,
  });

  @override
  State<MultiFilePicker> createState() => _MultiFilePickerState();
}

class _MultiFilePickerState extends State<MultiFilePicker> {
  bool _isPicking = false;

  Future<void> _pickFiles() async {
    setState(() {
      _isPicking = true;
    });

    try {
      if (widget.resourceType == ResourceType.image) {
        final picker = ImagePicker();
        final images = await picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (images.isNotEmpty) {
          final platformFiles = await Future.wait(
            images.map((image) async {
              final file = File(image.path);
              final bytes = await file.readAsBytes();
              return PlatformFile(
                name: image.name,
                path: image.path,
                size: bytes.length,
                bytes: bytes,
              );
            }),
          );

          widget.onAddFiles?.call(platformFiles);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: _getFileType(),
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          widget.onAddFiles?.call(result.files);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  FileType _getFileType() {
    switch (widget.resourceType) {
      case ResourceType.document:
        return FileType.custom;
      case ResourceType.image:
        return FileType.image;
      case ResourceType.video:
        return FileType.video;
      case ResourceType.audio:
        return FileType.audio;
      case ResourceType.archive:
        return FileType.custom;
      case ResourceType.other:
        return FileType.any;
    }
  }

  String _getFileTypeDescription() {
    switch (widget.resourceType) {
      case ResourceType.document:
        return 'Supports PDF, DOC, DOCX, TXT, RTF';
      case ResourceType.image:
        return 'Supports JPG, PNG, GIF, WebP';
      case ResourceType.video:
        return 'Supports MP4, AVI, MOV, WMV';
      case ResourceType.audio:
        return 'Supports MP3, WAV, AAC, FLAC';
      case ResourceType.archive:
        return 'Supports ZIP, RAR, 7Z, TAR';
      case ResourceType.other:
        return 'All file types supported';
    }
  }

  IconData _getPickerIcon() {
    switch (widget.resourceType) {
      case ResourceType.image:
        return Iconsax.gallery_add;
      case ResourceType.video:
        return Iconsax.video_add;
      case ResourceType.audio:
        return Icons.music_note;
      default:
        return Iconsax.document_upload;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File Type Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.resourceType.color.withAlpha(25), // 0.1 * 255 = 25
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.resourceType.color.withAlpha(76), // 0.3 * 255 = 76
            ),
          ),
          child: Row(
            children: [
              Icon(
                FileTypeIcons.getIconForType(widget.resourceType),
                color: widget.resourceType.color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resourceType.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.resourceType.color,
                      ),
                    ),
                    Text(
                      _getFileTypeDescription(),
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
        const SizedBox(height: 16),

        // Pick Files Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isPicking ? null : _pickFiles,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isPicking)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        _getPickerIcon(),
                        size: 48,
                        color: Colors.blue.withAlpha(178), // 0.7 * 255 = 178
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _isPicking ? 'Selecting files...' : 'Click to select files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isPicking ? Colors.grey : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedFiles.isEmpty
                          ? 'No files selected'
                          : '${widget.selectedFiles.length} file(s) selected',
                      style: TextStyle(
                        color: widget.selectedFiles.isEmpty ? Colors.grey : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Selected Files List
        if (widget.selectedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Files',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = widget.selectedFiles[index];
                    final isPrimary = index == widget.primaryFileIndex;

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index == widget.selectedFiles.length - 1 ? 0 : 1,
                      ),
                      decoration: BoxDecoration(
                        color: isPrimary ? Colors.blue.withAlpha(13) : Colors.white, // 0.05 * 255 = 13
                        border: isPrimary
                            ? Border.all(color: Colors.blue.withAlpha(76)) // 0.3 * 255 = 76
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPrimary ? Colors.blue.withAlpha(25) : Colors.grey[100], // 0.1 * 255 = 25
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPrimary ? Colors.blue : Colors.transparent,
                              width: isPrimary ? 2 : 0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              FileUtils.getFileIcon(file.path ?? file.name),
                              size: 20,
                              color: isPrimary ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                        title: Text(
                          file.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isPrimary ? Colors.blue : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          FileUtils.formatBytes(file.size),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Primary Badge
                            if (isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(25), // 0.1 * 255 = 25
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            // Set Primary Button
                            if (!isPrimary && widget.selectedFiles.length > 1)
                              IconButton(
                                onPressed: () => widget.onSetPrimaryFile(index),
                                icon: const Icon(
                                  Iconsax.star,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                tooltip: 'Set as Primary',
                              ),

                            // Remove Button
                            IconButton(
                              onPressed: () => widget.onRemoveFile(index),
                              icon: const Icon(
                                Iconsax.close_circle,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (widget.selectedFiles.length > 1)
                Text(
                  'Primary file will be used as thumbnail',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
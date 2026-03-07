import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/resources/file_utils.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(List<PlatformFile>) onFilesSelected;
  final List<String> allowedExtensions;
  final bool allowMultiple;
  final String? label;
  final String? hintText;

  const FilePickerWidget({
    super.key,
    required this.onFilesSelected,
    this.allowedExtensions = const [],
    this.allowMultiple = true,
    this.label,
    this.hintText,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  Future<void> _pickFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: widget.allowMultiple,
        withData: true,
        withReadStream: false,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
        widget.onFilesSelected(_selectedFiles);
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
        _isLoading = false;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  void _clearAll() {
    setState(() {
      _selectedFiles.clear();
    });
    widget.onFilesSelected(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),

        // File Picker Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFiles.isEmpty ? Colors.grey[300]! : Colors.blue.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickFiles,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        Iconsax.document_upload,
                        size: 48,
                        color: Colors.blue.withValues(alpha: 0.7),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      widget.hintText ?? 'Select files',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getFileTypeDescription(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFiles.isEmpty
                          ? 'No files selected'
                          : '${_selectedFiles.length} file(s) selected',
                      style: TextStyle(
                        color: _selectedFiles.isEmpty ? Colors.grey : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Total size: ${_getTotalSize()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Selected Files List
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: _clearAll,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == _selectedFiles.length - 1 ? 0 : 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: index == 0
                        ? Border(
                      top: BorderSide(color: Colors.grey[200]!),
                      bottom: BorderSide(color: Colors.grey[200]!),
                    )
                        : Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          FileUtils.getFileIcon(file.name),
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    title: Text(
                      file.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      FileUtils.formatBytes(file.size),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      onPressed: () => _removeFile(index),
                      icon: const Icon(Iconsax.close_circle, size: 20, color: Colors.red),
                      tooltip: 'Remove',
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // File Type Info
        if (widget.allowedExtensions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Allowed file types: ${widget.allowedExtensions.map((e) => ".$e").join(", ")}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  String _getFileTypeDescription() {
    if (widget.allowedExtensions.isEmpty) {
      return 'All file types supported';
    }

    final extensions = widget.allowedExtensions;

    // Check for common categories
    final imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final docExts = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    final spreadsheetExts = ['xls', 'xlsx', 'csv'];
    final presentationExts = ['ppt', 'pptx'];

    if (extensions.every((ext) => imageExts.contains(ext.toLowerCase()))) {
      return 'Image files only';
    } else if (extensions.every((ext) => docExts.contains(ext.toLowerCase()))) {
      return 'Document files only';
    } else if (extensions.every((ext) => spreadsheetExts.contains(ext.toLowerCase()))) {
      return 'Spreadsheet files only';
    } else if (extensions.every((ext) => presentationExts.contains(ext.toLowerCase()))) {
      return 'Presentation files only';
    }

    return 'Supported: ${extensions.map((e) => ".$e").join(", ")}';
  }

  String _getTotalSize() {
    final totalBytes = _selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
    return FileUtils.formatBytes(totalBytes);
  }
}
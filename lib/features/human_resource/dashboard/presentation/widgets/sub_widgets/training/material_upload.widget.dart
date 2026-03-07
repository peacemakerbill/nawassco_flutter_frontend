import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class MaterialUpload extends ConsumerStatefulWidget {
  final Training training;

  const MaterialUpload({super.key, required this.training});

  @override
  ConsumerState<MaterialUpload> createState() => _MaterialUploadState();
}

class _MaterialUploadState extends ConsumerState<MaterialUpload> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final materials = widget.training.materials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Materials'),
        actions: [
          if (_selectedFiles.isNotEmpty && !_isUploading)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: _uploadFiles,
              tooltip: 'Upload Selected Files',
            ),
        ],
      ),
      body: Column(
        children: [
          // Upload section
          if (_selectedFiles.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Upload Training Materials',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload presentations, documents, videos, or other training materials',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Select Files'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(bottom: BorderSide(color: Colors.orange.shade100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedFiles.length} file(s) selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedFiles.clear()),
                        tooltip: 'Clear All',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._selectedFiles.map((file) {
                    return ListTile(
                      leading: _getFileIcon(file.path),
                      title: Text(file.name),
                      subtitle: Text('${_getFileSize(file)} KB'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() => _selectedFiles.remove(file));
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  if (!_isUploading)
                    ElevatedButton.icon(
                      onPressed: _uploadFiles,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Files'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
              ),
            ),

          // Upload progress
          if (_isUploading)
            const LinearProgressIndicator(),

          // Materials list
          Expanded(
            child: materials.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No materials uploaded yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload your first training material',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return _buildMaterialCard(material);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(TrainingMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(material.fileIcon, color: Colors.blue),
        ),
        title: Text(material.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${material.fileType} • ${DateFormat('dd MMM yyyy').format(material.uploadDate)}'),
            Text('Uploaded by: ${material.uploadedBy}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () => _downloadMaterial(material),
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMaterial(material),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Icon _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['pdf'].contains(ext)) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (['doc', 'docx'].contains(ext)) {
      return const Icon(Icons.description, color: Colors.blue);
    } else if (['ppt', 'pptx'].contains(ext)) {
      return const Icon(Icons.slideshow, color: Colors.orange);
    } else if (['xls', 'xlsx'].contains(ext)) {
      return const Icon(Icons.table_chart, color: Colors.green);
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return const Icon(Icons.image, color: Colors.purple);
    } else if (['mp4', 'avi', 'mov'].contains(ext)) {
      return const Icon(Icons.video_library, color: Colors.red);
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  String _getFileSize(XFile file) {
    try {
      final fileSize = File(file.path).lengthSync();
      return (fileSize / 1024).toStringAsFixed(1);
    } catch (e) {
      return '0';
    }
  }

  Future<void> _pickFiles() async {
    final files = await _picker.pickMultiImage();
    if (files != null && files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(files));
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _selectedFiles.add(photo));
    }
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    for (final file in _selectedFiles) {
      await ref.read(trainingProvider.notifier).uploadMaterial(
        widget.training.id,
        file,
      );
    }

    setState(() {
      _isUploading = false;
      _selectedFiles.clear();
    });
  }

  Future<void> _downloadMaterial(TrainingMaterial material) async {
    final url = Uri.parse(material.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _deleteMaterial(TrainingMaterial material) async {
    // Implement delete functionality
    // This would call the backend API
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';
import '../../../utils/resources/file_type_icons.dart';
import '../../sub_widgets/resources/multi_file_picker.dart';

class CreateResourceDialog extends ConsumerStatefulWidget {
  const CreateResourceDialog({super.key});

  @override
  ConsumerState<CreateResourceDialog> createState() => _CreateResourceDialogState();
}

class _CreateResourceDialogState extends ConsumerState<CreateResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _metaTitleController = TextEditingController();
  final TextEditingController _metaDescriptionController = TextEditingController();

  ResourceType _selectedType = ResourceType.document;
  ResourceCategory _selectedCategory = ResourceCategory.other;
  AccessLevel _selectedAccessLevel = AccessLevel.public;

  bool _isFeatured = false;
  bool _requiresAuth = false;
  int _sortOrder = 0;
  int _primaryFileIndex = 0;

  List<String> _tags = [];
  List<String> _keywords = [];
  List<String> _allowedRoles = [];
  List<String> _allowedServiceZones = [];

  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<String> _availableRoles = [
    'Admin',
    'Manager',
    'Staff',
    'SalesAgent',
    'Accounts',
    'HR',
    'Procurement',
    'Technician',
    'StoreManager',
    'Supplier',
    'User',
  ];

  final List<String> _availableServiceZones = [
    'North Zone',
    'South Zone',
    'East Zone',
    'West Zone',
    'Central Zone',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addKeyword() {
    final keyword = _keywordsController.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordsController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  Future<void> _pickFiles() async {
    if (_selectedType == ResourceType.image) {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            images.map((image) => PlatformFile(
              name: image.name,
              path: image.path,
              size: File(image.path).lengthSync(),
              bytes: File(image.path).readAsBytesSync(),
            )).toList(),
          );
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: _getFileType(),
      );
      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    }
  }

  FileType _getFileType() {
    switch (_selectedType) {
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

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      if (_primaryFileIndex >= _selectedFiles.length) {
        _primaryFileIndex = _selectedFiles.length - 1;
      }
    });
  }

  void _setPrimaryFile(int index) {
    setState(() {
      _primaryFileIndex = index;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final notifier = ref.read(resourceProvider.notifier);
    final resource = await notifier.createResource(
      title: _titleController.text,
      description: _descriptionController.text,
      resourceType: _selectedType,
      category: _selectedCategory,
      files: _selectedFiles,
      accessLevel: _selectedAccessLevel,
      allowedRoles: _allowedRoles,
      allowedServiceZones: _allowedServiceZones.isNotEmpty ? _allowedServiceZones : null,
      tags: _tags,
      keywords: _keywords,
      isFeatured: _isFeatured,
      requiresAuth: _requiresAuth,
      sortOrder: _sortOrder,
      metaTitle: _metaTitleController.text.isNotEmpty ? _metaTitleController.text : null,
      metaDescription: _metaDescriptionController.text.isNotEmpty ? _metaDescriptionController.text : null,
    );

    setState(() {
      _isUploading = false;
    });

    if (resource != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resource "${resource.title}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: _isUploading
            ? _buildUploadProgress()
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Iconsax.add_circle, size: 28, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text(
                        'Create New Resource',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter resource title',
                      prefixIcon: Icon(Iconsax.text),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter resource description',
                      prefixIcon: Icon(Iconsax.text_block),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Type & Category
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ResourceType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Resource Type *',
                            prefixIcon: Icon(Iconsax.document),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          items: ResourceType.values.map((type) {
                            return DropdownMenuItem<ResourceType>(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(FileTypeIcons.getIconForType(type), size: 20),
                                  const SizedBox(width: 8),
                                  Text(type.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<ResourceCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(Iconsax.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          items: ResourceCategory.values.map((category) {
                            return DropdownMenuItem<ResourceCategory>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(category.icon, size: 20),
                                  const SizedBox(width: 8),
                                  Text(category.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // File Upload Section
                  const Text(
                    'Files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedFiles.length} file(s)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // File Picker
                  MultiFilePicker(
                    selectedFiles: _selectedFiles,
                    resourceType: _selectedType,
                    primaryFileIndex: _primaryFileIndex,
                    onPickFiles: _pickFiles,
                    onRemoveFile: _removeFile,
                    onSetPrimaryFile: _setPrimaryFile,
                  ),
                  const SizedBox(height: 24),

                  // Access Control
                  const Text(
                    'Access Control',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Access Level
                  DropdownButtonFormField<AccessLevel>(
                    value: _selectedAccessLevel,
                    decoration: const InputDecoration(
                      labelText: 'Access Level',
                      prefixIcon: Icon(Iconsax.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: AccessLevel.values.map((level) {
                      return DropdownMenuItem<AccessLevel>(
                        value: level,
                        child: Row(
                          children: [
                            Icon(level.icon, size: 20, color: level.color),
                            const SizedBox(width: 8),
                            Text(level.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAccessLevel = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Allowed Roles (multi-select)
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Allowed Roles',
                      prefixIcon: Icon(Iconsax.security_user),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableRoles.map((role) {
                        final isSelected = _allowedRoles.contains(role);
                        return FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _allowedRoles.add(role);
                              } else {
                                _allowedRoles.remove(role);
                              }
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue : Colors.grey[600],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Allowed Service Zones
                  if (_selectedAccessLevel != AccessLevel.public)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Allowed Service Zones',
                            prefixIcon: Icon(Iconsax.location),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableServiceZones.map((zone) {
                              final isSelected = _allowedServiceZones.contains(zone);
                              return FilterChip(
                                label: Text(zone),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _allowedServiceZones.add(zone);
                                    } else {
                                      _allowedServiceZones.remove(zone);
                                    }
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.green.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.green : Colors.grey[600],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Featured & Auth
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Featured Resource'),
                          subtitle: const Text('Show in featured section'),
                          value: _isFeatured,
                          onChanged: (value) {
                            setState(() {
                              _isFeatured = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Requires Authentication'),
                          subtitle: const Text('Users must be logged in'),
                          value: _requiresAuth,
                          onChanged: (value) {
                            setState(() {
                              _requiresAuth = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sort Order
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      hintText: '0',
                      prefixIcon: Icon(Iconsax.sort),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      _sortOrder = int.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tags & Keywords
                  const Text(
                    'Metadata',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Add tags (press Enter)',
                          prefixIcon: const Icon(Iconsax.tag),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.add),
                            onPressed: _addTag,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                            deleteIcon: const Icon(Iconsax.close_circle, size: 16),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Keywords
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _keywordsController,
                        decoration: InputDecoration(
                          labelText: 'Keywords',
                          hintText: 'Add keywords (press Enter)',
                          prefixIcon: const Icon(Iconsax.key),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.add),
                            onPressed: _addKeyword,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onFieldSubmitted: (_) => _addKeyword(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _keywords.map((keyword) {
                          return Chip(
                            label: Text(keyword),
                            onDeleted: () => _removeKeyword(keyword),
                            deleteIcon: const Icon(Iconsax.close_circle, size: 16),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SEO Metadata
                  const Text(
                    'SEO Metadata (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _metaTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Meta Title',
                      hintText: 'For SEO purposes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _metaDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Meta Description',
                      hintText: 'For SEO purposes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // Actions
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create Resource'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Uploading ${_selectedFiles.length} file(s)...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we upload your files...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../providers/accountant_providers.dart';

class QualificationFormDialog extends ConsumerStatefulWidget {
  const QualificationFormDialog({super.key});

  @override
  ConsumerState<QualificationFormDialog> createState() =>
      _QualificationFormDialogState();
}

class _QualificationFormDialogState
    extends ConsumerState<QualificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _issuingOrganizationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedQualificationType;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  List<int>? _documentBytes;
  String? _fileName;
  bool _isLoading = false;

  final List<String> _qualificationTypes = [
    'CPA Certification',
    'ACCA Certification',
    'CMA Certification',
    'Bachelor Degree',
    'Master Degree',
    'Diploma',
    'Certificate',
    'Training',
    'Workshop',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuingOrganizationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _documentBytes = bytes;
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addQualification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'type': _selectedQualificationType,
        'issuingOrganization': _issuingOrganizationCtrl.text.trim(),
        'issueDate': _issueDate?.toIso8601String(),
        'expiryDate': _expiryDate?.toIso8601String(),
        'description': _descriptionCtrl.text.trim(),
      };

      await ref.read(accountantProfileProvider.notifier).addQualification(
            data,
            _documentBytes,
            _fileName,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Qualification added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add qualification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate
          ? (_issueDate ?? DateTime.now())
          : (_expiryDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school_rounded,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Qualification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Qualification Name *',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter qualification name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedQualificationType,
                        decoration: const InputDecoration(
                          labelText: 'Qualification Type',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Select Type',
                                  style: TextStyle(color: Colors.grey))),
                          ..._qualificationTypes.map((type) =>
                              DropdownMenuItem(value: type, child: Text(type))),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedQualificationType = value),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _issuingOrganizationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Issuing Organization *',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter issuing organization'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Date Fields
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildDateField('Issue Date', _issueDate, true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                                'Expiry Date', _expiryDate, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          filled: true,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Document Upload
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supporting Document',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _fileName ?? 'No document selected',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _pickDocument,
                              icon: const Icon(Icons.attach_file_rounded),
                              label: const Text('Choose Document'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addQualification,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Add Qualification'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isIssueDate) {
    return InkWell(
      onTap: () => _selectDate(context, isIssueDate),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(),
          filled: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select $label',
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

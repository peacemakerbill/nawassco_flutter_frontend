import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/reports/management_report_model.dart';
import '../../../../providers/management_report_provider.dart';

class ReportFormDialog extends ConsumerStatefulWidget {
  final ManagementReport? report;

  const ReportFormDialog({super.key, this.report});

  @override
  ConsumerState<ReportFormDialog> createState() => _ReportFormDialogState();
}

class _ReportFormDialogState extends ConsumerState<ReportFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late ReportType _selectedType;
  late ReportFrequency _selectedFrequency;
  late ConfidentialityLevel _selectedConfidentiality;
  late DateTime _startDate;
  late DateTime? _endDate;

  // Store sections as ReportSection objects
  late List<ReportSection> _sections;

  // Controllers for editing sections
  late List<TextEditingController> _sectionTitleControllers;
  late List<TextEditingController> _sectionContentControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.report?.title ?? '',
    );
    _summaryController = TextEditingController(
      text: widget.report?.executiveSummary ?? '',
    );
    _selectedType = widget.report?.type ?? ReportType.operational;
    _selectedFrequency = widget.report?.frequency ?? ReportFrequency.monthly;
    _selectedConfidentiality = widget.report?.confidentiality ?? ConfidentialityLevel.internal;
    _startDate = widget.report?.startDate ?? DateTime.now();
    _endDate = widget.report?.endDate;

    // Initialize sections from existing report or empty list
    _sections = widget.report?.sections != null
        ? List<ReportSection>.from(widget.report!.sections)
        : [];

    // Initialize controllers for each section
    _sectionTitleControllers = _sections
        .map((section) => TextEditingController(text: section.title))
        .toList();
    _sectionContentControllers = _sections
        .map((section) => TextEditingController(text: section.content))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();

    // Dispose all section controllers
    for (var controller in _sectionTitleControllers) {
      controller.dispose();
    }
    for (var controller in _sectionContentControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _addSection() {
    setState(() {
      final newSection = ReportSection(title: '', content: '');
      _sections.add(newSection);
      _sectionTitleControllers.add(TextEditingController(text: newSection.title));
      _sectionContentControllers.add(TextEditingController(text: newSection.content));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
      _sectionTitleControllers[index].dispose();
      _sectionContentControllers[index].dispose();
      _sectionTitleControllers.removeAt(index);
      _sectionContentControllers.removeAt(index);
    });
  }

  void _updateSection(int index, String title, String content) {
    setState(() {
      _sections[index] = _sections[index].copyWith(
        title: title,
        content: content,
      );
    });
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      // Update all sections with current controller values
      for (int i = 0; i < _sections.length; i++) {
        _updateSection(
          i,
          _sectionTitleControllers[i].text,
          _sectionContentControllers[i].text,
        );
      }

      final reportData = {
        'title': _titleController.text.trim(),
        'type': _selectedType.name,
        'frequency': _selectedFrequency.name,
        'confidentiality': _selectedConfidentiality.name,
        'executiveSummary': _summaryController.text.trim(),
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'sections': _sections.map((s) => s.toJson()).toList(),
      };

      if (widget.report != null) {
        ref.read(managementReportProvider.notifier).updateReport(
          widget.report!.id,
          reportData,
        );
      } else {
        ref.read(managementReportProvider.notifier).createReport(reportData);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.report != null ? 'Edit Report' : 'Create New Report',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Report Title',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ReportType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Report Type',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: ReportType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 20),
                                  const SizedBox(width: 8),
                                  Text(type.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<ReportFrequency>(
                          value: _selectedFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: ReportFrequency.values.map((freq) {
                            return DropdownMenuItem(
                              value: freq,
                              child: Text(freq.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedFrequency = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ConfidentialityLevel>(
                          value: _selectedConfidentiality,
                          decoration: const InputDecoration(
                            labelText: 'Confidentiality',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: ConfidentialityLevel.values.map((level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: level.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(level.displayName),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedConfidentiality = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(
                      labelText: 'Executive Summary',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Sections',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addSection,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _sectionTitleControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Section Title',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _updateSection(
                                      index,
                                      value,
                                      _sectionContentControllers[index].text,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _sectionContentControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Content',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  onChanged: (value) {
                                    _updateSection(
                                      index,
                                      _sectionTitleControllers[index].text,
                                      value,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSection(index),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/job_model.dart';

class JobFilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialFilters;
  final ValueChanged<Map<String, dynamic>> onApplyFilters;

  const JobFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  late Map<String, dynamic> _filters;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);

    _titleController.text = _filters['title'] ?? '';
    _locationController.text = _filters['location'] ?? '';
    _minSalaryController.text = _filters['minSalary']?.toString() ?? '';
    _maxSalaryController.text = _filters['maxSalary']?.toString() ?? '';
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_titleController.text.trim().isNotEmpty) {
      filters['title'] = _titleController.text.trim();
    }
    if (_locationController.text.trim().isNotEmpty) {
      filters['location'] = _locationController.text.trim();
    }
    if (_minSalaryController.text.trim().isNotEmpty) {
      filters['minSalary'] = double.tryParse(_minSalaryController.text);
    }
    if (_maxSalaryController.text.trim().isNotEmpty) {
      filters['maxSalary'] = double.tryParse(_maxSalaryController.text);
    }

    // Add other filters
    for (var entry in _filters.entries) {
      if (entry.key != 'title' &&
          entry.key != 'location' &&
          entry.key != 'minSalary' &&
          entry.key != 'maxSalary' &&
          entry.value != null) {
        filters[entry.key] = entry.value;
      }
    }

    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _titleController.clear();
      _locationController.clear();
      _minSalaryController.clear();
      _maxSalaryController.clear();
    });
    widget.onApplyFilters({});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Jobs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Search
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Type
                  const Text('Job Type',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: JobType.values.map((type) {
                      final isSelected = _filters['jobType'] == type.name;
                      return FilterChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filters['jobType'] = type.name;
                            } else {
                              _filters.remove('jobType');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Position Type
                  const Text('Position Level',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: PositionType.values.map((type) {
                      final isSelected = _filters['positionType'] == type.name;
                      return FilterChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filters['positionType'] = type.name;
                            } else {
                              _filters.remove('positionType');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Work Mode
                  const Text('Work Mode',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: WorkMode.values.map((mode) {
                      final isSelected = _filters['workMode'] == mode.name;
                      return FilterChip(
                        label: Text(mode.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filters['workMode'] = mode.name;
                            } else {
                              _filters.remove('workMode');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Salary Range
                  const Text('Salary Range',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minSalaryController,
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxSalaryController,
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status (for HR/Admin)
                  const Text('Status',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: JobStatus.values.map((status) {
                      final isSelected = _filters['status'] == status.name;
                      return FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filters['status'] = status.name;
                            } else {
                              _filters.remove('status');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Checkboxes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('Remote Friendly Only'),
                            value: _filters['isRemoteFriendly'] == true,
                            onChanged: (value) {
                              setState(() {
                                _filters['isRemoteFriendly'] = value;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Internships Only'),
                            value: _filters['isInternship'] == true,
                            onChanged: (value) {
                              setState(() {
                                _filters['isInternship'] = value;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Attachments Only'),
                            value: _filters['isAttachment'] == true,
                            onChanged: (value) {
                              setState(() {
                                _filters['isAttachment'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

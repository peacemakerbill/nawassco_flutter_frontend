import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class OutageFormWidget extends StatefulWidget {
  final Outage? outage;
  final Function(Outage) onSave;
  final VoidCallback onCancel;

  const OutageFormWidget({
    super.key,
    this.outage,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<OutageFormWidget> createState() => _OutageFormWidgetState();
}

class _OutageFormWidgetState extends State<OutageFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Outage _outage;
  final List<AffectedArea> _affectedAreas = [];

  @override
  void initState() {
    super.initState();
    _outage = widget.outage ??
        Outage(
          outageNumber: '',
          title: '',
          description: '',
          type: OutageType.EMERGENCY,
          category: OutageCategory.DISTRIBUTION,
          status: OutageStatus.REPORTED,
          priority: PriorityLevel.MEDIUM,
          affectedAreas: [],
          estimatedAffectedCustomers: 0,
          estimatedDuration: 0,
          assignedCrew: [],
          requiredResources: [],
          equipmentUsed: [],
          publicNotifications: [],
          internalCommunications: [],
          impact: ImpactAssessment(
            residentialCustomers: 0,
            commercialCustomers: 0,
            industrialCustomers: 0,
            criticalFacilities: [],
            waterPressureImpact: PressureImpact.NONE,
          ),
          customerUpdates: [],
          documents: [],
          images: [],
          reportedBy: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.outage == null ? 'Create New Outage' : 'Edit Outage',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOutage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionHeader('Basic Information'),
              TextFormField(
                initialValue: _outage.title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter outage title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _outage = _outage.copyWith(title: value ?? '');
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _outage.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the outage',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _outage = _outage.copyWith(description: value ?? '');
                },
              ),

              const SizedBox(height: 24),

              // Type and Priority
              _buildSectionHeader('Classification'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<OutageType>(
                      value: _outage.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: OutageType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.toString().split('.').last.replaceAll('_', ' '),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _outage = _outage.copyWith(type: value!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<OutageCategory>(
                      value: _outage.category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: OutageCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.toString().split('.').last.replaceAll('_', ' '),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _outage = _outage.copyWith(category: value!);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PriorityLevel>(
                value: _outage.priority,
                decoration: const InputDecoration(
                  labelText: 'Priority Level',
                  border: OutlineInputBorder(),
                ),
                items: PriorityLevel.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.toString().split('.').last),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _outage = _outage.copyWith(priority: value!);
                  });
                },
              ),

              const SizedBox(height: 24),

              // Affected Areas
              _buildSectionHeader('Affected Areas'),
              ..._buildAffectedAreasSection(),

              const SizedBox(height: 24),

              // Timing
              _buildSectionHeader('Timing'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _outage.estimatedDuration.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _outage = _outage.copyWith(
                          estimatedDuration: int.tryParse(value ?? '0') ?? 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _outage.estimatedAffectedCustomers.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Estimated Affected Customers',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of customers';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _outage = _outage.copyWith(
                          estimatedAffectedCustomers: int.tryParse(value ?? '0') ?? 0,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Cause and Resolution
              _buildSectionHeader('Cause & Resolution'),
              DropdownButtonFormField<OutageCause?>(
                value: _outage.cause,
                decoration: const InputDecoration(
                  labelText: 'Cause',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select cause'),
                  ),
                  ...OutageCause.values.map((cause) {
                    return DropdownMenuItem(
                      value: cause,
                      child: Text(
                        cause.toString().split('.').last.replaceAll('_', ' '),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _outage = _outage.copyWith(cause: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _outage.rootCause,
                decoration: const InputDecoration(
                  labelText: 'Root Cause (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) {
                  _outage = _outage.copyWith(rootCause: value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _outage.resolutionDetails,
                decoration: const InputDecoration(
                  labelText: 'Resolution Plan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _outage = _outage.copyWith(resolutionDetails: value);
                },
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveOutage,
                      child: const Text('Save Outage'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildAffectedAreasSection() {
    return [
      ..._outage.affectedAreas.map((area) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.zone,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Subzone: ${area.subzone}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Estimated Customers: ${area.estimatedCustomers}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    setState(() {
                      _outage = _outage.copyWith(
                        affectedAreas: _outage.affectedAreas
                            .where((a) => a != area)
                            .toList(),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _addAffectedArea,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Affected Area'),
      ),
    ];
  }

  void _addAffectedArea() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Affected Area'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Zone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Subzone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Customers',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Add area logic
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.LOW:
        return Colors.green;
      case PriorityLevel.MEDIUM:
        return Colors.blue;
      case PriorityLevel.HIGH:
        return Colors.orange;
      case PriorityLevel.CRITICAL:
        return Colors.red;
    }
  }

  void _saveOutage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSave(_outage);
    }
  }
}
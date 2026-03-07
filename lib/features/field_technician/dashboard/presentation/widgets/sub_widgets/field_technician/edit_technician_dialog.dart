import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_technician.dart';
import '../../../../providers/field_technician_provider.dart';

class EditTechnicianDialog extends ConsumerStatefulWidget {
  final FieldTechnician? technician;

  const EditTechnicianDialog({super.key, this.technician});

  @override
  ConsumerState<EditTechnicianDialog> createState() =>
      _EditTechnicianDialogState();
}

class _EditTechnicianDialogState extends ConsumerState<EditTechnicianDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _workZoneCtrl = TextEditingController();

  FieldTechnicianRole _selectedRole = FieldTechnicianRole.fieldTechnician;
  DateTime? _hireDate;
  DateTime? _dateOfBirth;
  final List<String> _selectedSpecializations = [];
  final List<String> _selectedRegions = [];

  @override
  void initState() {
    super.initState();
    if (widget.technician != null) {
      _firstNameCtrl.text = widget.technician!.firstName;
      _lastNameCtrl.text = widget.technician!.lastName;
      _emailCtrl.text = widget.technician!.email;
      _phoneCtrl.text = widget.technician!.phone;
      _nationalIdCtrl.text = widget.technician!.nationalId;
      _workZoneCtrl.text = widget.technician!.workZone;
      _selectedRole = widget.technician!.jobTitle;
      _hireDate = widget.technician!.hireDate;
      _dateOfBirth = widget.technician!.dateOfBirth;
      _selectedSpecializations.addAll(widget.technician!.specializedAreas);
      _selectedRegions.addAll(widget.technician!.assignedRegions);
    } else {
      _hireDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalIdCtrl.dispose();
    _workZoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isHireDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isHireDate
          ? _hireDate ?? DateTime.now()
          : _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isHireDate) {
          _hireDate = picked;
        } else {
          _dateOfBirth = picked;
        }
      });
    }
  }

  Future<void> _saveTechnician() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim().toLowerCase(),
      'phone': _phoneCtrl.text.trim(),
      'nationalId': _nationalIdCtrl.text.trim(),
      'workZone': _workZoneCtrl.text.trim(),
      'jobTitle': _selectedRole.name,
      'hireDate': _hireDate?.toIso8601String(),
      'dateOfBirth': _dateOfBirth?.toIso8601String(),
      'specializedAreas': _selectedSpecializations,
      'assignedRegions': _selectedRegions,
      'department': 'Field Operations',
    };

    final notifier = ref.read(fieldTechnicianProvider.notifier);
    final success = widget.technician != null
        ? await notifier.updateTechnicianProfile(widget.technician!.id, data)
        : await notifier.createTechnicianProfile(data);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.technician != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
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
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Technician' : 'Add New Technician',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Personal Information
                _buildSection('Personal Information', [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nationalIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'National ID',
                      prefixIcon: Icon(Icons.badge_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter national ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake_rounded),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              color: _dateOfBirth != null
                                  ? theme.colorScheme.onSurface
                                  : theme.hintColor,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Employment Information
                _buildSection('Employment Information', [
                  DropdownButtonFormField<FieldTechnicianRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                      prefixIcon: Icon(Icons.work_rounded),
                    ),
                    items: FieldTechnicianRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(role.icon, color: role.color, size: 16),
                            const SizedBox(width: 8),
                            Text(role.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _workZoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Work Zone',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter work zone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hire Date',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _hireDate != null
                                ? '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              color: _hireDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.hintColor,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Specializations
                _buildSection('Specializations', [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Water Supply Network',
                      'Sanitation Systems',
                      'Pump Stations',
                      'Water Treatment Plants',
                      'Meter Installation',
                      'Leak Detection',
                      'Pressure Management',
                      'Water Quality Monitoring',
                    ].map((specialization) {
                      final isSelected =
                          _selectedSpecializations.contains(specialization);
                      return FilterChip(
                        label: Text(specialization),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSpecializations.add(specialization);
                            } else {
                              _selectedSpecializations.remove(specialization);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ]),

                const SizedBox(height: 24),

                // Assigned Regions
                _buildSection('Assigned Regions', [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Central Zone',
                      'North Zone',
                      'South Zone',
                      'East Zone',
                      'West Zone',
                      'Industrial Area',
                      'Commercial District',
                      'Residential Areas',
                    ].map((region) {
                      final isSelected = _selectedRegions.contains(region);
                      return FilterChip(
                        label: Text(region),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRegions.add(region);
                            } else {
                              _selectedRegions.remove(region);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ]),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTechnician,
                        child: Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../models/applicant/applicant_model.dart';

class JobPreferencesForm extends StatefulWidget {
  final JobPreferences? preferences;
  final Function(JobPreferences) onSubmit;

  const JobPreferencesForm({
    super.key,
    this.preferences,
    required this.onSubmit,
  });

  @override
  _JobPreferencesFormState createState() => _JobPreferencesFormState();
}

class _JobPreferencesFormState extends State<JobPreferencesForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedJobTypes = [];
  final List<String> _selectedPositionTypes = [];
  final List<String> _selectedWorkModes = [];
  final List<TextEditingController> _locationControllers = [];
  final List<TextEditingController> _industryControllers = [];
  final List<TextEditingController> _relocationControllers = [];
  late TextEditingController _minimumSalaryController;
  late TextEditingController _noticePeriodController;
  late TextEditingController _availableFromController;
  String _currency = 'USD';
  bool _remoteOnly = false;
  bool _visaSponsorshipRequired = false;
  bool _willingToRelocate = false;

  final List<String> _jobTypes = [
    'full_time',
    'part_time',
    'contract',
    'internship',
    'freelance',
    'temporary'
  ];

  final List<String> _positionTypes = [
    'entry_level',
    'mid_level',
    'senior',
    'lead',
    'manager',
    'director',
    'executive'
  ];

  final List<String> _workModes = ['office', 'remote', 'hybrid'];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'KES',
    'INR',
    'CAD',
    'AUD'
  ];

  @override
  void initState() {
    super.initState();
    _minimumSalaryController = TextEditingController(
        text: widget.preferences?.minimumSalary?.toString() ?? '');
    _noticePeriodController = TextEditingController(
        text: (widget.preferences?.noticePeriod ?? 30).toString());
    _availableFromController = TextEditingController(
        text: widget.preferences?.availableFrom != null
            ? widget.preferences!.availableFrom!.toIso8601String().split('T')[0]
            : '');
    _currency = widget.preferences?.currency ?? 'USD';
    _remoteOnly = widget.preferences?.remoteOnly ?? false;
    _visaSponsorshipRequired =
        widget.preferences?.visaSponsorshipRequired ?? false;
    _willingToRelocate = widget.preferences?.willingToRelocate ?? false;

    // Initialize lists from preferences
    _selectedJobTypes.addAll(widget.preferences?.preferredJobTypes ?? []);
    _selectedPositionTypes
        .addAll(widget.preferences?.preferredPositionTypes ?? []);
    _selectedWorkModes.addAll(widget.preferences?.preferredWorkModes ?? []);

    _locationControllers.addAll(widget.preferences?.preferredLocations
            .map((loc) => TextEditingController(text: loc))
            .toList() ??
        [TextEditingController()]);

    _industryControllers.addAll(widget.preferences?.preferredIndustries
            .map((ind) => TextEditingController(text: ind))
            .toList() ??
        [TextEditingController()]);

    _relocationControllers.addAll(widget.preferences?.relocationLocations
            ?.map((loc) => TextEditingController(text: loc))
            .toList() ??
        [TextEditingController()]);
  }

  @override
  void dispose() {
    _minimumSalaryController.dispose();
    _noticePeriodController.dispose();
    _availableFromController.dispose();
    for (var controller in _locationControllers) controller.dispose();
    for (var controller in _industryControllers) controller.dispose();
    for (var controller in _relocationControllers) controller.dispose();
    super.dispose();
  }

  Future<void> _selectAvailableFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _availableFromController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _addLocation() {
    setState(() {
      _locationControllers.add(TextEditingController());
    });
  }

  void _removeLocation(int index) {
    if (_locationControllers.length > 1) {
      setState(() {
        _locationControllers[index].dispose();
        _locationControllers.removeAt(index);
      });
    }
  }

  void _addIndustry() {
    setState(() {
      _industryControllers.add(TextEditingController());
    });
  }

  void _removeIndustry(int index) {
    if (_industryControllers.length > 1) {
      setState(() {
        _industryControllers[index].dispose();
        _industryControllers.removeAt(index);
      });
    }
  }

  void _addRelocationLocation() {
    setState(() {
      _relocationControllers.add(TextEditingController());
    });
  }

  void _removeRelocationLocation(int index) {
    if (_relocationControllers.length > 1) {
      setState(() {
        _relocationControllers[index].dispose();
        _relocationControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Job Types
            const Text(
              'Preferred Job Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _jobTypes.map((type) {
                final isSelected = _selectedJobTypes.contains(type);
                return FilterChip(
                  label: Text(type.replaceAll('_', ' ').toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedJobTypes.add(type);
                      } else {
                        _selectedJobTypes.remove(type);
                      }
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Position Types
            const Text(
              'Preferred Position Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _positionTypes.map((type) {
                final isSelected = _selectedPositionTypes.contains(type);
                return FilterChip(
                  label: Text(type.replaceAll('_', ' ').toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPositionTypes.add(type);
                      } else {
                        _selectedPositionTypes.remove(type);
                      }
                    });
                  },
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Work Modes
            const Text(
              'Preferred Work Modes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _workModes.map((mode) {
                final isSelected = _selectedWorkModes.contains(mode);
                return FilterChip(
                  label: Text(mode.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkModes.add(mode);
                      } else {
                        _selectedWorkModes.remove(mode);
                      }
                    });
                  },
                  selectedColor: Colors.orange[100],
                  checkmarkColor: Colors.orange,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Remote Only Checkbox
            Row(
              children: [
                Checkbox(
                  value: _remoteOnly,
                  onChanged: (value) {
                    setState(() {
                      _remoteOnly = value ?? false;
                    });
                  },
                ),
                const Text('Remote Work Only'),
              ],
            ),
            const SizedBox(height: 16),

            // Preferred Locations
            const Text(
              'Preferred Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            ..._locationControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Location ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeLocation(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addLocation,
              icon: const Icon(Icons.add_location),
              label: const Text('Add Location'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),

            // Preferred Industries
            const Text(
              'Preferred Industries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            ..._industryControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Industry ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.business),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeIndustry(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addIndustry,
              icon: const Icon(Icons.add_business),
              label: const Text('Add Industry'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // Visa Sponsorship
            Row(
              children: [
                Checkbox(
                  value: _visaSponsorshipRequired,
                  onChanged: (value) {
                    setState(() {
                      _visaSponsorshipRequired = value ?? false;
                    });
                  },
                ),
                const Text('Visa Sponsorship Required'),
              ],
            ),
            const SizedBox(height: 16),

            // Salary Expectations
            const Text(
              'Salary Expectations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minimumSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Expected Salary',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _currency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Relocation
            const Text(
              'Relocation Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Checkbox(
                  value: _willingToRelocate,
                  onChanged: (value) {
                    setState(() {
                      _willingToRelocate = value ?? false;
                    });
                  },
                ),
                const Text('Willing to Relocate'),
              ],
            ),

            if (_willingToRelocate) ...[
              const SizedBox(height: 12),
              const Text(
                'Preferred Relocation Locations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              ..._relocationControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Location ${index + 1}',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.flight_takeoff),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeRelocationLocation(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton.icon(
                onPressed: _addRelocationLocation,
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add Relocation Location'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.purple[50],
                  foregroundColor: Colors.purple,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Notice Period
            const Text(
              'Notice Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _noticePeriodController,
              decoration: const InputDecoration(
                labelText: 'Notice Period (Days)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter notice period';
                }
                final days = int.tryParse(value);
                if (days == null || days < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Available From
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _availableFromController,
              decoration: InputDecoration(
                labelText: 'Available From',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectAvailableFrom(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectAvailableFrom(context),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final preferences = JobPreferences(
                    preferredJobTypes: _selectedJobTypes,
                    preferredPositionTypes: _selectedPositionTypes,
                    preferredWorkModes: _selectedWorkModes,
                    preferredLocations: _locationControllers
                        .where((c) => c.text.isNotEmpty)
                        .map((c) => c.text)
                        .toList(),
                    preferredIndustries: _industryControllers
                        .where((c) => c.text.isNotEmpty)
                        .map((c) => c.text)
                        .toList(),
                    remoteOnly: _remoteOnly,
                    visaSponsorshipRequired: _visaSponsorshipRequired,
                    minimumSalary: _minimumSalaryController.text.isNotEmpty
                        ? double.tryParse(_minimumSalaryController.text)
                        : null,
                    currency: _currency,
                    willingToRelocate: _willingToRelocate,
                    relocationLocations: _willingToRelocate &&
                            _relocationControllers.any((c) => c.text.isNotEmpty)
                        ? _relocationControllers
                            .where((c) => c.text.isNotEmpty)
                            .map((c) => c.text)
                            .toList()
                        : null,
                    noticePeriod: int.parse(_noticePeriodController.text),
                    availableFrom: _availableFromController.text.isNotEmpty
                        ? DateTime.parse(_availableFromController.text)
                        : null,
                  );

                  widget.onSubmit(preferences);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Preferences'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

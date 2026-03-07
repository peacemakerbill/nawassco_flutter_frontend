import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/field_team.dart';
import '../../../../providers/field_technician_provider.dart';

class FieldTeamFormWidget extends ConsumerStatefulWidget {
  final FieldTeam? team;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const FieldTeamFormWidget({
    super.key,
    this.team,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<FieldTeamFormWidget> createState() =>
      _FieldTeamFormWidgetState();
}

class _FieldTeamFormWidgetState extends ConsumerState<FieldTeamFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _departmentController = TextEditingController();

  String? _selectedTeamLead;
  List<String> _selectedSpecializations = [];
  List<String> _selectedWorkZones = [];
  List<String> _selectedMembers = [];

  final List<String> _availableSpecializations = [
    'Leak Repair',
    'Meter Installation',
    'Pipe Replacement',
    'Water Quality',
    'Network Maintenance',
    'Emergency Response',
    'Preventive Maintenance',
  ];

  final List<String> _availableWorkZones = [
    'Central Zone',
    'North Zone',
    'South Zone',
    'East Zone',
    'West Zone',
    'Downtown',
    'Industrial Area',
    'Residential Area',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.team != null) {
      _teamNameController.text = widget.team!.teamName;
      _descriptionController.text = widget.team!.description;
      _departmentController.text = widget.team!.department;
      _selectedTeamLead = widget.team!.teamLeadId;
      _selectedSpecializations = List.from(widget.team!.specialization);
      _selectedWorkZones = List.from(widget.team!.workZones);
      _selectedMembers = List.from(widget.team!.memberIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final techniciansState = ref.watch(fieldTechnicianProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _teamNameController,
                        decoration: const InputDecoration(
                          labelText: 'Team Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.groups),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a team name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a department';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Team Composition Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Team Composition',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Team Lead Selection
                      DropdownButtonFormField<String>(
                        value: _selectedTeamLead,
                        decoration: const InputDecoration(
                          labelText: 'Team Lead',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: techniciansState.technicians
                            .where((tech) => tech.isActive)
                            .map((technician) => DropdownMenuItem(
                                  value: technician.id,
                                  child: Text(technician.fullName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTeamLead = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a team lead';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Team Members Selection
                      const Text(
                        'Team Members',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...techniciansState.technicians
                          .where((tech) =>
                              tech.isActive && tech.id != _selectedTeamLead)
                          .map((technician) => CheckboxListTile(
                                title: Text(technician.fullName),
                                subtitle: Text(technician.jobTitle.displayName),
                                value: _selectedMembers.contains(technician.id),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedMembers.add(technician.id);
                                    } else {
                                      _selectedMembers.remove(technician.id);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Specializations & Work Zones Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Capabilities & Coverage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Specializations
                      const Text(
                        'Specializations',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSpecializations
                            .map((spec) => FilterChip(
                                  label: Text(spec),
                                  selected:
                                      _selectedSpecializations.contains(spec),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedSpecializations.add(spec);
                                      } else {
                                        _selectedSpecializations.remove(spec);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 16),

                      // Work Zones
                      const Text(
                        'Work Zones',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableWorkZones
                            .map((zone) => FilterChip(
                                  label: Text(zone),
                                  selected: _selectedWorkZones.contains(zone),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedWorkZones.add(zone);
                                      } else {
                                        _selectedWorkZones.remove(zone);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTeam,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Save Team'),
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

  void _saveTeam() {
    if (_formKey.currentState!.validate()) {
      final teamData = {
        'teamName': _teamNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'department': _departmentController.text.trim(),
        'teamLead': _selectedTeamLead,
        'members': _selectedMembers,
        'specialization': _selectedSpecializations,
        'workZones': _selectedWorkZones,
        'workSchedule': {
          'shift': 'Day',
          'startTime': '08:00',
          'endTime': '17:00',
          'workingDays': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        },
      };

      widget.onSave(teamData);
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../../../../../../models/applicant/work_experience_model.dart';

class WorkExperienceForm extends StatefulWidget {
  final WorkExperienceModel? experience;
  final Function(WorkExperienceModel) onSubmit;

  const WorkExperienceForm({
    super.key,
    this.experience,
    required this.onSubmit,
  });

  @override
  _WorkExperienceFormState createState() => _WorkExperienceFormState();
}

class _WorkExperienceFormState extends State<WorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employerController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late List<TextEditingController> _responsibilityControllers;
  late List<TextEditingController> _achievementControllers;
  late List<TextEditingController> _skillsControllers;
  late TextEditingController _referenceNameController;
  late TextEditingController _referencePositionController;
  late TextEditingController _referenceCompanyController;
  late TextEditingController _referenceEmailController;
  late TextEditingController _referencePhoneController;
  late TextEditingController _referenceRelationshipController;

  String _employmentType = 'full_time';
  bool _isCurrent = false;
  bool _hasReference = false;
  bool _canContact = true;

  final List<String> _employmentTypes = [
    'full_time',
    'part_time',
    'contract',
    'internship',
    'freelance',
    'temporary',
    'volunteer'
  ];

  @override
  void initState() {
    super.initState();
    _employerController = TextEditingController(text: widget.experience?.employer ?? '');
    _positionController = TextEditingController(text: widget.experience?.position ?? '');
    _locationController = TextEditingController(text: widget.experience?.location ?? '');
    _descriptionController = TextEditingController(text: widget.experience?.description ?? '');
    _startDateController = TextEditingController(
        text: widget.experience != null ?
        '${widget.experience!.startDate.year}-${widget.experience!.startDate.month.toString().padLeft(2, '0')}' : ''
    );
    _endDateController = TextEditingController(
        text: widget.experience?.endDate != null ?
        '${widget.experience!.endDate!.year}-${widget.experience!.endDate!.month.toString().padLeft(2, '0')}' : ''
    );
    _employmentType = widget.experience?.employmentType ?? 'full_time';
    _isCurrent = widget.experience?.isCurrent ?? false;

    // Initialize lists
    _responsibilityControllers = widget.experience?.responsibilities.map((r) => TextEditingController(text: r)).toList() ?? [TextEditingController()];
    _achievementControllers = widget.experience?.achievements.map((a) => TextEditingController(text: a)).toList() ?? [TextEditingController()];
    _skillsControllers = widget.experience?.skillsUsed.map((s) => TextEditingController(text: s)).toList() ?? [TextEditingController()];

    // Reference contact
    _referenceNameController = TextEditingController(text: widget.experience?.referenceContact?.name ?? '');
    _referencePositionController = TextEditingController(text: widget.experience?.referenceContact?.position ?? '');
    _referenceCompanyController = TextEditingController(text: widget.experience?.referenceContact?.company ?? '');
    _referenceEmailController = TextEditingController(text: widget.experience?.referenceContact?.email ?? '');
    _referencePhoneController = TextEditingController(text: widget.experience?.referenceContact?.phone ?? '');
    _referenceRelationshipController = TextEditingController(text: widget.experience?.referenceContact?.relationship ?? '');
    _hasReference = widget.experience?.referenceContact != null;
    _canContact = widget.experience?.referenceContact?.canContact ?? true;
  }

  @override
  void dispose() {
    _employerController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (var controller in _responsibilityControllers) controller.dispose();
    for (var controller in _achievementControllers) controller.dispose();
    for (var controller in _skillsControllers) controller.dispose();
    _referenceNameController.dispose();
    _referencePositionController.dispose();
    _referenceCompanyController.dispose();
    _referenceEmailController.dispose();
    _referencePhoneController.dispose();
    _referenceRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  void _addResponsibility() {
    setState(() {
      _responsibilityControllers.add(TextEditingController());
    });
  }

  void _removeResponsibility(int index) {
    if (_responsibilityControllers.length > 1) {
      setState(() {
        _responsibilityControllers[index].dispose();
        _responsibilityControllers.removeAt(index);
      });
    }
  }

  void _addAchievement() {
    setState(() {
      _achievementControllers.add(TextEditingController());
    });
  }

  void _removeAchievement(int index) {
    if (_achievementControllers.length > 1) {
      setState(() {
        _achievementControllers[index].dispose();
        _achievementControllers.removeAt(index);
      });
    }
  }

  void _addSkill() {
    setState(() {
      _skillsControllers.add(TextEditingController());
    });
  }

  void _removeSkill(int index) {
    if (_skillsControllers.length > 1) {
      setState(() {
        _skillsControllers[index].dispose();
        _skillsControllers.removeAt(index);
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
            // Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),

            // Employer
            TextFormField(
              controller: _employerController,
              decoration: const InputDecoration(
                labelText: 'Employer/Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Position
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Position/Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter position';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Employment Type
            DropdownButtonFormField<String>(
              value: _employmentType,
              decoration: const InputDecoration(
                labelText: 'Employment Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
              items: _employmentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _employmentType = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'e.g. Nairobi, Kenya',
              ),
            ),
            const SizedBox(height: 12),

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () => _selectStartDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectStartDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _isCurrent ? null : () => _selectEndDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: _isCurrent ? null : () => _selectEndDate(context),
                    enabled: !_isCurrent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Current Position Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isCurrent,
                  onChanged: (value) {
                    setState(() {
                      _isCurrent = value ?? false;
                      if (_isCurrent) {
                        _endDateController.clear();
                      }
                    });
                  },
                ),
                const Text('I currently work here'),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter job description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Responsibilities
            const Text(
              'Responsibilities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            ..._responsibilityControllers.asMap().entries.map((entry) {
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
                          labelText: 'Responsibility ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.arrow_right, size: 20),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeResponsibility(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addResponsibility,
              icon: const Icon(Icons.add),
              label: const Text('Add Responsibility'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Achievements
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            ..._achievementControllers.asMap().entries.map((entry) {
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
                          labelText: 'Achievement ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.star, size: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeAchievement(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addAchievement,
              icon: const Icon(Icons.add),
              label: const Text('Add Achievement'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.amber[50],
                foregroundColor: Colors.amber[800],
              ),
            ),
            const SizedBox(height: 16),

            // Skills Used
            const Text(
              'Skills Used',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            ..._skillsControllers.asMap().entries.map((entry) {
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
                          labelText: 'Skill ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.code, size: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeSkill(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            ElevatedButton.icon(
              onPressed: _addSkill,
              icon: const Icon(Icons.add),
              label: const Text('Add Skill'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),

            // Reference Contact
            const Text(
              'Reference Contact',
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
                  value: _hasReference,
                  onChanged: (value) {
                    setState(() {
                      _hasReference = value ?? false;
                    });
                  },
                ),
                const Text('Add reference contact for this position'),
              ],
            ),

            if (_hasReference) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceNameController,
                decoration: const InputDecoration(
                  labelText: 'Reference Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referencePositionController,
                decoration: const InputDecoration(
                  labelText: 'Reference Position',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceCompanyController,
                decoration: const InputDecoration(
                  labelText: 'Reference Company',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceEmailController,
                decoration: const InputDecoration(
                  labelText: 'Reference Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referencePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Reference Phone (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceRelationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                  hintText: 'e.g. Manager, Supervisor, Colleague',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _canContact,
                    onChanged: (value) {
                      setState(() {
                        _canContact = value ?? true;
                      });
                    },
                  ),
                  const Text('Can be contacted for reference'),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final startParts = _startDateController.text.split('-');
                  final endParts = _isCurrent ? null : _endDateController.text.split('-');

                  final experience = WorkExperienceModel(
                    id: widget.experience?.id,
                    employer: _employerController.text,
                    position: _positionController.text,
                    employmentType: _employmentType,
                    startDate: DateTime(
                      int.parse(startParts[0]),
                      int.parse(startParts[1]),
                      1,
                    ),
                    endDate: _isCurrent ? null : (endParts != null && endParts.length == 2)
                        ? DateTime(int.parse(endParts[0]), int.parse(endParts[1]), 1)
                        : null,
                    isCurrent: _isCurrent,
                    location: _locationController.text.isNotEmpty ? _locationController.text : null,
                    description: _descriptionController.text,
                    responsibilities: _responsibilityControllers
                        .where((c) => c.text.isNotEmpty)
                        .map((c) => c.text)
                        .toList(),
                    achievements: _achievementControllers
                        .where((c) => c.text.isNotEmpty)
                        .map((c) => c.text)
                        .toList(),
                    skillsUsed: _skillsControllers
                        .where((c) => c.text.isNotEmpty)
                        .map((c) => c.text)
                        .toList(),
                    referenceContact: _hasReference &&
                        _referenceNameController.text.isNotEmpty &&
                        _referencePositionController.text.isNotEmpty &&
                        _referenceCompanyController.text.isNotEmpty &&
                        _referenceEmailController.text.isNotEmpty
                        ? ReferenceContact(
                      name: _referenceNameController.text,
                      position: _referencePositionController.text,
                      company: _referenceCompanyController.text,
                      email: _referenceEmailController.text,
                      phone: _referencePhoneController.text.isNotEmpty ? _referencePhoneController.text : null,
                      relationship: _referenceRelationshipController.text,
                      canContact: _canContact,
                    )
                        : null,
                  );

                  widget.onSubmit(experience);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Experience'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
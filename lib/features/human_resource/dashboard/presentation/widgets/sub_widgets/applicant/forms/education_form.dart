import 'package:flutter/material.dart';
import '../../../../../../models/applicant/education_model.dart';

class EducationForm extends StatefulWidget {
  final EducationModel? education;
  final Function(EducationModel) onSubmit;

  const EducationForm({
    super.key,
    this.education,
    required this.onSubmit,
  });

  @override
  _EducationFormState createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _institutionController;
  late TextEditingController _qualificationController;
  late TextEditingController _fieldOfStudyController;
  late TextEditingController _gradeController;
  late TextEditingController _gpaController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isCurrent = false;
  bool _isVerified = false;

  final List<String> _qualifications = [
    'High School',
    'Certificate',
    'Diploma',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Post-Doctoral'
  ];

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController(text: widget.education?.institution ?? '');
    _qualificationController = TextEditingController(text: widget.education?.qualification ?? '');
    _fieldOfStudyController = TextEditingController(text: widget.education?.fieldOfStudy ?? '');
    _gradeController = TextEditingController(text: widget.education?.grade ?? '');
    _gpaController = TextEditingController(text: widget.education?.gpa?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.education?.description ?? '');
    _startDateController = TextEditingController(
        text: widget.education != null ?
        '${widget.education!.startDate.year}-${widget.education!.startDate.month.toString().padLeft(2, '0')}' : ''
    );
    _endDateController = TextEditingController(
        text: widget.education?.endDate != null ?
        '${widget.education!.endDate!.year}-${widget.education!.endDate!.month.toString().padLeft(2, '0')}' : ''
    );
    _isCurrent = widget.education?.isCurrent ?? false;
    _isVerified = widget.education?.isVerified ?? false;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _qualificationController.dispose();
    _fieldOfStudyController.dispose();
    _gradeController.dispose();
    _gpaController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Institution
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter institution name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Qualification
            DropdownButtonFormField<String>(
              value: _qualificationController.text.isNotEmpty ? _qualificationController.text : null,
              decoration: const InputDecoration(
                labelText: 'Qualification',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.workspace_premium),
              ),
              items: _qualifications.map((qualification) {
                return DropdownMenuItem(
                  value: qualification,
                  child: Text(qualification),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _qualificationController.text = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select qualification';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Field of Study
            TextFormField(
              controller: _fieldOfStudyController,
              decoration: const InputDecoration(
                labelText: 'Field of Study',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
                hintText: 'e.g. Computer Science, Business Administration',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter field of study';
                }
                return null;
              },
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

            // Current Education Checkbox
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
                const Text('Currently studying here'),
              ],
            ),
            const SizedBox(height: 12),

            // Grade and GPA Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                      hintText: 'e.g. A, First Class',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _gpaController,
                    decoration: const InputDecoration(
                      labelText: 'GPA',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.score),
                      hintText: 'e.g. 3.8',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            // Verified Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isVerified,
                  onChanged: (value) {
                    setState(() {
                      _isVerified = value ?? false;
                    });
                  },
                ),
                const Text('Verified'),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final startParts = _startDateController.text.split('-');
                  final endParts = _isCurrent ? null : _endDateController.text.split('-');

                  final education = EducationModel(
                    id: widget.education?.id,
                    institution: _institutionController.text,
                    qualification: _qualificationController.text,
                    fieldOfStudy: _fieldOfStudyController.text,
                    startDate: DateTime(
                      int.parse(startParts[0]),
                      int.parse(startParts[1]),
                      1,
                    ),
                    endDate: _isCurrent ? null : (endParts != null && endParts.length == 2)
                        ? DateTime(int.parse(endParts[0]), int.parse(endParts[1]), 1)
                        : null,
                    grade: _gradeController.text.isNotEmpty ? _gradeController.text : null,
                    gpa: _gpaController.text.isNotEmpty ? double.tryParse(_gpaController.text) : null,
                    description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                    isCurrent: _isCurrent,
                    isVerified: _isVerified,
                  );

                  widget.onSubmit(education);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Education'),
            ),
          ],
        ),
      ),
    );
  }
}
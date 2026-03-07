import 'package:flutter/material.dart';
import '../../../../../models/job_model.dart';

class EducationRequirementInput extends StatefulWidget {
  final List<EducationRequirement> initialRequirements;
  final ValueChanged<List<EducationRequirement>> onChanged;

  const EducationRequirementInput({
    super.key,
    required this.initialRequirements,
    required this.onChanged,
  });

  @override
  State<EducationRequirementInput> createState() =>
      _EducationRequirementInputState();
}

class _EducationRequirementInputState extends State<EducationRequirementInput> {
  final List<EducationRequirement> _requirements = [];
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  InstitutionType _selectedType = InstitutionType.ANY;

  @override
  void initState() {
    super.initState();
    _requirements.addAll(widget.initialRequirements);
  }

  void _addRequirement() {
    final degree = _degreeController.text.trim();
    if (degree.isNotEmpty) {
      final requirement = EducationRequirement(
        degree: degree,
        fieldOfStudy: _fieldController.text.trim().isEmpty
            ? null
            : _fieldController.text.trim(),
        minimumGrade: _gradeController.text.trim().isEmpty
            ? null
            : _gradeController.text.trim(),
        institutionType:
            _selectedType == InstitutionType.ANY ? null : _selectedType,
      );

      setState(() {
        _requirements.add(requirement);
        _clearForm();
        widget.onChanged(_requirements);
      });
    }
  }

  void _clearForm() {
    _degreeController.clear();
    _fieldController.clear();
    _gradeController.clear();
    _selectedType = InstitutionType.ANY;
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
      widget.onChanged(_requirements);
    });
  }

  void _editRequirement(int index, EducationRequirement requirement) {
    _degreeController.text = requirement.degree;
    _fieldController.text = requirement.fieldOfStudy ?? '';
    _gradeController.text = requirement.minimumGrade ?? '';
    _selectedType = requirement.institutionType ?? InstitutionType.ANY;

    _removeRequirement(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _degreeController,
                  decoration: const InputDecoration(
                    labelText: 'Degree/Qualification*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fieldController,
                  decoration: const InputDecoration(
                    labelText: 'Field of Study (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gradeController,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Grade (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.grade),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<InstitutionType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Institution Type',
                          border: OutlineInputBorder(),
                        ),
                        items: InstitutionType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value ?? InstitutionType.ANY;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addRequirement,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Add Education Requirement'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Requirements List
        if (_requirements.isEmpty)
          const Center(
            child: Text(
              'No education requirements added yet',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else
          ..._requirements.asMap().entries.map((entry) {
            final index = entry.key;
            final requirement = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(requirement.degree),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (requirement.fieldOfStudy != null)
                      Text('Field: ${requirement.fieldOfStudy}'),
                    if (requirement.minimumGrade != null)
                      Text('Minimum Grade: ${requirement.minimumGrade}'),
                    if (requirement.institutionType != null)
                      Text(
                          'Institution: ${requirement.institutionType!.displayName}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editRequirement(index, requirement),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeRequirement(index),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

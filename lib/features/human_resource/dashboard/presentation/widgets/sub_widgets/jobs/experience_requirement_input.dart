import 'package:flutter/material.dart';
import '../../../../../models/job_model.dart';

class ExperienceRequirementInput extends StatefulWidget {
  final ExperienceRequirement initialRequirement;
  final ValueChanged<ExperienceRequirement> onChanged;

  const ExperienceRequirementInput({
    super.key,
    required this.initialRequirement,
    required this.onChanged,
  });

  @override
  State<ExperienceRequirementInput> createState() =>
      _ExperienceRequirementInputState();
}

class _ExperienceRequirementInputState
    extends State<ExperienceRequirementInput> {
  late TextEditingController _yearsController;
  late ExperienceLevel _selectedLevel;
  late bool _industrySpecific;

  @override
  void initState() {
    super.initState();
    _yearsController = TextEditingController(
      text: widget.initialRequirement.years.toString(),
    );
    _selectedLevel = widget.initialRequirement.level;
    _industrySpecific = widget.initialRequirement.industrySpecific;
  }

  void _updateRequirement() {
    final years = int.tryParse(_yearsController.text) ?? 0;
    final requirement = ExperienceRequirement(
      years: years,
      level: _selectedLevel,
      industrySpecific: _industrySpecific,
    );
    widget.onChanged(requirement);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experience Requirement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearsController,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timeline),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateRequirement(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ExperienceLevel>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ExperienceLevel.values
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value ?? _selectedLevel;
                        _updateRequirement();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Industry-specific experience required'),
              value: _industrySpecific,
              onChanged: (value) {
                setState(() {
                  _industrySpecific = value ?? false;
                  _updateRequirement();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

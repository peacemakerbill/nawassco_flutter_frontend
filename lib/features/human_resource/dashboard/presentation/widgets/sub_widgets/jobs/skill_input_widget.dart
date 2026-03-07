import 'package:flutter/material.dart';
import '../../../../../models/job_model.dart';

class SkillInputWidget extends StatefulWidget {
  final List<SkillRequirement> initialSkills;
  final ValueChanged<List<SkillRequirement>> onChanged;

  const SkillInputWidget({
    super.key,
    required this.initialSkills,
    required this.onChanged,
  });

  @override
  State<SkillInputWidget> createState() => _SkillInputWidgetState();
}

class _SkillInputWidgetState extends State<SkillInputWidget> {
  final List<SkillRequirement> _skills = [];
  final TextEditingController _skillController = TextEditingController();
  ProficiencyLevel _selectedProficiency = ProficiencyLevel.INTERMEDIATE;
  bool _isRequired = true;

  @override
  void initState() {
    super.initState();
    _skills.addAll(widget.initialSkills);
  }

  void _addSkill() {
    final skillName = _skillController.text.trim();
    if (skillName.isNotEmpty) {
      final skill = SkillRequirement(
        skill: skillName,
        proficiency: _selectedProficiency,
        isRequired: _isRequired,
      );

      setState(() {
        _skills.add(skill);
        _skillController.clear();
        widget.onChanged(_skills);
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
      widget.onChanged(_skills);
    });
  }

  void _updateSkill(int index, SkillRequirement updatedSkill) {
    setState(() {
      _skills[index] = updatedSkill;
      widget.onChanged(_skills);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Skill Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skillController,
                        decoration: const InputDecoration(
                          labelText: 'Skill Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.code),
                        ),
                        onFieldSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _addSkill,
                      child: const Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 4),
                          Text('Add'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ProficiencyLevel>(
                        value: _selectedProficiency,
                        decoration: const InputDecoration(
                          labelText: 'Proficiency Level',
                          border: OutlineInputBorder(),
                        ),
                        items: ProficiencyLevel.values
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.displayName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProficiency =
                                value ?? ProficiencyLevel.INTERMEDIATE;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Required'),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value ?? true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Skills List
        if (_skills.isEmpty)
          const Center(
            child: Text(
              'No skills added yet',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else
          ..._skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: skill.isRequired ? Colors.red : Colors.blue,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(skill.skill),
                subtitle: Text(skill.proficiency.displayName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditSkillDialog(index, skill),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSkill(index),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showEditSkillDialog(int index, SkillRequirement skill) {
    final skillController = TextEditingController(text: skill.skill);
    ProficiencyLevel proficiency = skill.proficiency;
    bool isRequired = skill.isRequired;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: skillController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProficiencyLevel>(
              value: proficiency,
              decoration: const InputDecoration(
                labelText: 'Proficiency Level',
                border: OutlineInputBorder(),
              ),
              items: ProficiencyLevel.values
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                proficiency = value ?? proficiency;
              },
            ),
            CheckboxListTile(
              title: const Text('Required'),
              value: isRequired,
              onChanged: (value) {
                isRequired = value ?? true;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSkill = SkillRequirement(
                skill: skillController.text.trim(),
                proficiency: proficiency,
                isRequired: isRequired,
              );
              _updateSkill(index, updatedSkill);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

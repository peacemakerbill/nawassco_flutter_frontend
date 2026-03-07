import 'package:flutter/material.dart';
import '../../../../../../models/applicant/skill_model.dart';

class SkillForm extends StatefulWidget {
  final SkillModel? skill;
  final Function(SkillModel) onSubmit;

  const SkillForm({
    super.key,
    this.skill,
    required this.onSubmit,
  });

  @override
  _SkillFormState createState() => _SkillFormState();
}

class _SkillFormState extends State<SkillForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _skillController;
  late TextEditingController _yearsController;
  late TextEditingController _lastUsedController;
  String _category = 'technical';
  String _proficiency = 'intermediate';
  bool _isVerified = false;

  final List<String> _categories = [
    'technical',
    'soft_skills',
    'language',
    'certification',
    'tool',
    'framework',
    'methodology'
  ];

  final List<String> _proficiencies = [
    'beginner',
    'basic',
    'intermediate',
    'advanced',
    'expert'
  ];

  @override
  void initState() {
    super.initState();
    _skillController = TextEditingController(text: widget.skill?.skill ?? '');
    _yearsController = TextEditingController(
        text: widget.skill?.yearsOfExperience.toString() ?? '0');
    _lastUsedController =
        TextEditingController(text: widget.skill?.lastUsed?.toString() ?? '');
    _category = widget.skill?.category ?? 'technical';
    _proficiency = widget.skill?.proficiency ?? 'intermediate';
    _isVerified = widget.skill?.isVerified ?? false;
  }

  @override
  void dispose() {
    _skillController.dispose();
    _yearsController.dispose();
    _lastUsedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Skill Name
          TextFormField(
            controller: _skillController,
            decoration: const InputDecoration(
              labelText: 'Skill Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.code),
              hintText: 'e.g. Flutter, Project Management, Python',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter skill name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Category
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryName(category)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 12),

          // Proficiency
          DropdownButtonFormField<String>(
            value: _proficiency,
            decoration: const InputDecoration(
              labelText: 'Proficiency Level',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.star),
            ),
            items: _proficiencies.map((proficiency) {
              return DropdownMenuItem(
                value: proficiency,
                child: Text(_getProficiencyName(proficiency)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _proficiency = value!;
              });
            },
          ),
          const SizedBox(height: 12),

          // Years of Experience
          TextFormField(
            controller: _yearsController,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timeline),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter years of experience';
              }
              final years = int.tryParse(value);
              if (years == null || years < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Last Used (Years Ago)
          TextFormField(
            controller: _lastUsedController,
            decoration: const InputDecoration(
              labelText: 'Last Used (Years Ago) - Optional',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
              hintText: 'e.g. 1 (for last year)',
            ),
            keyboardType: TextInputType.number,
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
                final skill = SkillModel(
                  id: widget.skill?.id,
                  skill: _skillController.text,
                  category: _category,
                  proficiency: _proficiency,
                  yearsOfExperience: int.parse(_yearsController.text),
                  lastUsed: _lastUsedController.text.isNotEmpty
                      ? int.parse(_lastUsedController.text)
                      : null,
                  isVerified: _isVerified,
                );

                widget.onSubmit(skill);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Skill'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'technical':
        return 'Technical Skill';
      case 'soft_skills':
        return 'Soft Skill';
      case 'language':
        return 'Language';
      case 'certification':
        return 'Certification';
      case 'tool':
        return 'Tool';
      case 'framework':
        return 'Framework';
      case 'methodology':
        return 'Methodology';
      default:
        return category.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getProficiencyName(String proficiency) {
    switch (proficiency) {
      case 'beginner':
        return 'Beginner';
      case 'basic':
        return 'Basic';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      case 'expert':
        return 'Expert';
      default:
        return proficiency.toUpperCase();
    }
  }
}

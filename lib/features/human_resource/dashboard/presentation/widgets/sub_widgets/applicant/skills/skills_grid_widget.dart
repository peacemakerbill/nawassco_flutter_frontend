import 'package:flutter/material.dart';
import '../../../../../../models/applicant/skill_model.dart';

class SkillsGridWidget extends StatelessWidget {
  final List<SkillModel> skills;
  final bool isLoading;
  final VoidCallback onAdd;
  final Function(SkillModel) onEdit;
  final Function(SkillModel) onDelete;

  const SkillsGridWidget({
    super.key,
    required this.skills,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: skills.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Skills Added',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your skills to showcase your capabilities',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Skill'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills by category
                  ..._groupSkillsByCategory().entries.map((entry) {
                    final category = entry.key;
                    final categorySkills = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          child: Text(
                            _getCategoryName(category),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categorySkills
                              .map((skill) => _buildSkillChip(skill))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Map<String, List<SkillModel>> _groupSkillsByCategory() {
    final Map<String, List<SkillModel>> grouped = {};

    for (final skill in skills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]!.add(skill);
    }

    return grouped;
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'technical':
        return 'Technical Skills';
      case 'soft_skills':
        return 'Soft Skills';
      case 'language':
        return 'Languages';
      case 'certification':
        return 'Certifications';
      case 'tool':
        return 'Tools';
      case 'framework':
        return 'Frameworks';
      case 'methodology':
        return 'Methodologies';
      default:
        return category.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildSkillChip(SkillModel skill) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.skill,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          if (skill.yearsOfExperience > 0)
            Text(
              '(${skill.yearsOfExperience}y)',
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
      backgroundColor: _getSkillColor(skill.proficiency),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => onDelete(skill),
      deleteIconColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.white),
      avatar: _getProficiencyIcon(skill.proficiency),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Color _getSkillColor(String proficiency) {
    switch (proficiency) {
      case 'expert':
        return Colors.deepPurple;
      case 'advanced':
        return Colors.blue;
      case 'intermediate':
        return Colors.green;
      case 'basic':
        return Colors.orange;
      case 'beginner':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget? _getProficiencyIcon(String proficiency) {
    switch (proficiency) {
      case 'expert':
        return const Icon(Icons.star, size: 16, color: Colors.white);
      case 'advanced':
        return const Icon(Icons.star_half, size: 16, color: Colors.white);
      case 'intermediate':
        return const Icon(Icons.check_circle, size: 16, color: Colors.white);
      case 'basic':
        return const Icon(Icons.info, size: 16, color: Colors.white);
      case 'beginner':
        return const Icon(Icons.person, size: 16, color: Colors.white);
      default:
        return null;
    }
  }
}

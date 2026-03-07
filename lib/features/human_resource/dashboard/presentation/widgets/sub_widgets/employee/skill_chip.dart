import 'package:flutter/material.dart';

import '../../../../../models/employee_model.dart';

class SkillChip extends StatelessWidget {
  final Skill skill;

  const SkillChip({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final proficiencyColor = _getProficiencyColor(skill.proficiency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: proficiencyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: proficiencyColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.skill,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: proficiencyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              skill.proficiency.toString().split('.').last[0],
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${skill.yearsOfExperience}y',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProficiencyColor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.basic:
        return Colors.blue;
      case ProficiencyLevel.intermediate:
        return Colors.green;
      case ProficiencyLevel.advanced:
        return Colors.orange;
      case ProficiencyLevel.expert:
        return Colors.purple;
      case ProficiencyLevel.native:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
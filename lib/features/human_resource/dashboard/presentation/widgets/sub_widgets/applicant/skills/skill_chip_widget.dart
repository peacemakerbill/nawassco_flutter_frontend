import 'package:flutter/material.dart';

import '../../../../../../models/applicant/skill_model.dart';

class SkillChipWidget extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback? onDelete;
  final bool editable;

  const SkillChipWidget({
    super.key,
    required this.skill,
    this.onDelete,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.skill,
            style: const TextStyle(fontSize: 13),
          ),
          if (skill.yearsOfExperience > 0) ...[
            const SizedBox(width: 4),
            Text(
              '(${skill.yearsOfExperience}y)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: _getSkillColor(skill.proficiency),
      deleteIcon: editable ? const Icon(Icons.close, size: 16) : null,
      onDeleted: editable ? onDelete : null,
      deleteIconColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.white),
      avatar: _getProficiencyIcon(skill.proficiency),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  Color _getSkillColor(String proficiency) {
    switch (proficiency) {
      case 'expert':
        return const Color(0xFF6A1B9A);
      case 'advanced':
        return const Color(0xFF1976D2);
      case 'intermediate':
        return const Color(0xFF388E3C);
      case 'basic':
        return const Color(0xFFF57C00);
      case 'beginner':
        return const Color(0xFFD32F2F);
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
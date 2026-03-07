import 'package:flutter/material.dart';
import '../../../../models/store_manager_model.dart';

class DevelopmentSection extends StatelessWidget {
  final StoreManager storeManager;

  const DevelopmentSection({super.key, required this.storeManager});

  @override
  Widget build(BuildContext context) {
    final developmentPlan = storeManager.developmentPlan;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Development Plan Overview
          _buildDevelopmentOverview(developmentPlan),
          const SizedBox(height: 16),

          // Development Areas
          _buildDevelopmentAreasCard(developmentPlan),
          const SizedBox(height: 16),

          // Training Programs
          _buildTrainingProgramsCard(),
          const SizedBox(height: 16),

          // Technical Skills
          _buildTechnicalSkillsCard(),
          const SizedBox(height: 16),

          // Certifications
          _buildCertificationsCard(),
        ],
      ),
    );
  }

  Widget _buildDevelopmentOverview(StoreDevelopmentPlan developmentPlan) {
    final totalAreas = developmentPlan.developmentAreas.length;
    final completedAreas = developmentPlan.developmentAreas
        .where((area) => area.progress >= 100).length;
    final inProgressAreas = developmentPlan.developmentAreas
        .where((area) => area.progress > 0 && area.progress < 100).length;
    final notStartedAreas = totalAreas - completedAreas - inProgressAreas;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader('Development Plan Overview', Icons.school),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildOverviewItem('Development Areas', totalAreas.toString(), Icons.list),
                _buildOverviewItem('Completed', completedAreas.toString(), Icons.check_circle, Colors.green),
                _buildOverviewItem('In Progress', inProgressAreas.toString(), Icons.autorenew, Colors.blue),
                _buildOverviewItem('Not Started', notStartedAreas.toString(), Icons.schedule, Colors.grey),
              ],
            ),

            const SizedBox(height: 16),

            // Target Positions
            if (developmentPlan.targetPositions.isNotEmpty) ...[
              const Text(
                'Target Positions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: developmentPlan.targetPositions.map((position) =>
                    Chip(
                      label: Text(position),
                      backgroundColor: Colors.purple[50],
                    ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentAreasCard(StoreDevelopmentPlan developmentPlan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Development Areas', Icons.timeline),
            const SizedBox(height: 16),

            if (developmentPlan.developmentAreas.isEmpty)
              const Center(
                child: Text(
                  'No development areas defined',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...developmentPlan.developmentAreas.map((area) =>
                  _buildDevelopmentAreaItem(area),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingProgramsCard() {
    final trainingPrograms = storeManager.developmentPlan.trainingPrograms;
    final technicalTraining = storeManager.technicalTraining;
    final allTraining = [...trainingPrograms, ...technicalTraining];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Training & Development', Icons.library_books),
            const SizedBox(height: 16),

            if (allTraining.isEmpty)
              const Center(
                child: Text(
                  'No training programs assigned',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...allTraining.map((training) =>
                  _buildTrainingItem(training),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalSkillsCard() {
    final skills = storeManager.developmentPlan.technicalSkills;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Technical Skills', Icons.computer),
            const SizedBox(height: 16),

            if (skills.isEmpty)
              const Center(
                child: Text(
                  'No technical skills recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) =>
                    _buildSkillChip(skill),
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Certifications', Icons.card_membership),
            const SizedBox(height: 16),

            if (storeManager.certifications.isEmpty)
              const Center(
                child: Text(
                  'No certifications recorded',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...storeManager.certifications.map((certification) =>
                  _buildCertificationItem(certification),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentAreaItem(StoreDevelopmentArea area) {
    final daysUntilDeadline = area.deadline.difference(DateTime.now()).inDays;
    Color statusColor;
    String statusText;

    if (area.progress >= 100) {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (daysUntilDeadline < 0) {
      statusColor = Colors.red;
      statusText = 'Overdue';
    } else if (daysUntilDeadline <= 7) {
      statusColor = Colors.orange;
      statusText = 'Due Soon';
    } else {
      statusColor = Colors.blue;
      statusText = 'In Progress';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  area.area,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(
                label: Text(statusText),
                backgroundColor: statusColor.withOpacity(0.1),
                labelStyle: TextStyle(color: statusColor),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Skill Levels
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Level',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      area.currentLevel,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Level',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      area.targetLevel,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress and Deadline
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    LinearProgressIndicator(
                      value: area.progress / 100,
                      backgroundColor: Colors.grey[200],
                      color: statusColor,
                    ),
                    Text(
                      '${area.progress.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deadline',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      area.deadline.toIso8601String().split('T')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: daysUntilDeadline < 0 ? Colors.red : null,
                      ),
                    ),
                    Text(
                      daysUntilDeadline < 0 ?
                      '${daysUntilDeadline.abs()} days overdue' :
                      '$daysUntilDeadline days left',
                      style: TextStyle(
                        fontSize: 10,
                        color: daysUntilDeadline < 0 ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Actions
          if (area.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Action Plan:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ...area.actions.map((action) =>
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                  child: Text('• $action'),
                ),
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrainingItem(dynamic training) {
    final isTechnical = training is TechnicalTraining;
    final program = training.program;
    final provider = training.provider;
    final status = training.status;
    final completionDate = training.completionDate;
    final impact = training.impact;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'planned':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (isTechnical) ...[
                  const SizedBox(height: 2),
                  Text(
                    (training as TechnicalTraining).category.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                if (completionDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Completed: ${completionDate.toIso8601String().split('T')[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  status.replaceAll('_', ' '),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (impact > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Impact: ${impact.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(TechnicalSkill skill) {
    Color proficiencyColor;

    switch (skill.proficiency) {
      case 'expert':
        proficiencyColor = Colors.green;
        break;
      case 'advanced':
        proficiencyColor = Colors.blue;
        break;
      case 'intermediate':
        proficiencyColor = Colors.orange;
        break;
      case 'basic':
        proficiencyColor = Colors.grey;
        break;
      default:
        proficiencyColor = Colors.grey;
    }

    return Chip(
      label: Text(skill.skill),
      avatar: CircleAvatar(
        backgroundColor: proficiencyColor.withOpacity(0.2),
        child: Text(
          skill.proficiency[0].toUpperCase(),
          style: TextStyle(
            color: proficiencyColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      side: BorderSide(color: proficiencyColor.withOpacity(0.3)),
    );
  }

  Widget _buildCertificationItem(StoreCertification certification) {
    final isExpired = certification.expiryDate != null &&
        certification.expiryDate!.isBefore(DateTime.now());
    final daysUntilExpiry = certification.expiryDate != null ?
    certification.expiryDate!.difference(DateTime.now()).inDays : null;

    Color statusColor;
    String statusText;

    if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Expired';
    } else if (daysUntilExpiry != null && daysUntilExpiry <= 30) {
      statusColor = Colors.orange;
      statusText = 'Expiring Soon';
    } else {
      statusColor = Colors.green;
      statusText = 'Valid';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.card_membership, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  certification.issuingAuthority,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Issued: ${certification.issueDate.toIso8601String().split('T')[0]}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (certification.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${certification.expiryDate!.toIso8601String().split('T')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired ? Colors.red : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (daysUntilExpiry != null && !isExpired) ...[
                const SizedBox(height: 4),
                Text(
                  '$daysUntilExpiry days left',
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.blue),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color ?? Colors.blue,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
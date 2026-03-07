import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/job_model.dart';

class JobDetailCard extends StatelessWidget {
  final Job job;

  const JobDetailCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 150,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade800,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.jobNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: job.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: job.statusColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                job.statusDisplay,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: job.statusColor,
                                ),
                              ),
                            ),
                            if (job.canApply)
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implement apply functionality
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Apply Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Overview
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOverviewGrid(),
                        const SizedBox(height: 24),

                        // Job Details
                        const Text(
                          'Job Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildJobDetails(),
                        const SizedBox(height: 24),

                        // Requirements
                        const Text(
                          'Requirements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRequirements(),
                        const SizedBox(height: 24),

                        // Responsibilities
                        const Text(
                          'Responsibilities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResponsibilities(),
                        const SizedBox(height: 24),

                        // Benefits
                        if (job.benefits.isNotEmpty) ...[
                          const Text(
                            'Benefits',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBenefits(),
                          const SizedBox(height: 24),
                        ],

                        // Skills
                        if (job.requiredSkills.isNotEmpty) ...[
                          const Text(
                            'Required Skills',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSkills(),
                          const SizedBox(height: 24),
                        ],

                        // Recruitment Process
                        if (job.recruitmentStages.isNotEmpty) ...[
                          const Text(
                            'Recruitment Process',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRecruitmentProcess(),
                          const SizedBox(height: 24),
                        ],

                        // Statistics
                        _buildStatistics(),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOverviewItem(
          icon: Icons.business,
          title: 'Department',
          value: job.department,
        ),
        _buildOverviewItem(
          icon: Icons.location_on,
          title: 'Location',
          value: job.location,
        ),
        _buildOverviewItem(
          icon: Icons.work,
          title: 'Job Type',
          value: job.jobType.displayName,
        ),
        _buildOverviewItem(
          icon: Icons.timeline,
          title: 'Position Level',
          value: job.positionType.displayName,
        ),
        _buildOverviewItem(
          icon: Icons.work_outline,
          title: 'Work Mode',
          value: job.workMode.displayName,
        ),
        _buildOverviewItem(
          icon: Icons.access_time,
          title: 'Duration',
          value: job.duration != null ? '${job.duration} months' : 'Permanent',
        ),
        _buildOverviewItem(
          icon: Icons.money,
          title: 'Salary',
          value: job.salaryRange.displayText,
        ),
        _buildOverviewItem(
          icon: Icons.event,
          title: 'Deadline',
          value: DateFormat('MMM dd, yyyy').format(job.applicationDeadline),
        ),
      ],
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Additional Info
        if (job.isRemoteFriendly || job.visaSponsorshipAvailable)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (job.isRemoteFriendly)
                    _buildInfoRow(
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      text: 'Remote work is allowed for this position',
                    ),
                  if (job.visaSponsorshipAvailable)
                    _buildInfoRow(
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      text: 'Visa sponsorship is available',
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Experience
            if (job.requiredExperience.years > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Experience Required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${job.requiredExperience.years} years (${job.requiredExperience.level.displayName})',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Education
            if (job.requiredEducation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Education Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...job.requiredEducation.map((education) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.school,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${education.degree}${education.fieldOfStudy != null ? ' in ${education.fieldOfStudy}' : ''}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ),

            // Requirements List
            const Text(
              'Key Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...job.requirements.map((requirement) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          requirement,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...job.responsibilities.map((responsibility) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          responsibility,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: job.benefits
          .map((benefit) => Chip(
                label: Text(benefit),
                backgroundColor: Colors.green.shade50,
                labelStyle: const TextStyle(color: Colors.green),
                side: BorderSide(color: Colors.green.shade200),
              ))
          .toList(),
    );
  }

  Widget _buildSkills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: job.requiredSkills
          .map((skill) => Chip(
                label:
                    Text('${skill.skill} (${skill.proficiency.displayName})'),
                backgroundColor:
                    skill.isRequired ? Colors.red.shade50 : Colors.blue.shade50,
                labelStyle: TextStyle(
                  color: skill.isRequired ? Colors.red : Colors.blue,
                  fontWeight:
                      skill.isRequired ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: skill.isRequired
                      ? Colors.red.shade200
                      : Colors.blue.shade200,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRecruitmentProcess() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...job.recruitmentStages.map((stage) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            stage.stageNumber.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stage.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${stage.estimatedDuration} days',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                if (!stage.isMandatory)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orange.shade200),
                                    ),
                                    child: Text(
                                      'Optional',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCircle(
              value: job.numberOfOpenings.toString(),
              label: 'Openings',
              color: Colors.blue,
            ),
            _buildStatCircle(
              value: job.numberOfApplications.toString(),
              label: 'Applications',
              color: Colors.green,
            ),
            _buildStatCircle(
              value: job.views.toString(),
              label: 'Views',
              color: Colors.orange,
            ),
            if (job.isPublished && job.publishDate != null)
              _buildStatCircle(
                value: DateFormat('MMM dd').format(job.publishDate!),
                label: 'Published',
                color: Colors.purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCircle({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

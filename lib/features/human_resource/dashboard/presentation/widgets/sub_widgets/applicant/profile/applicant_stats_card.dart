import 'package:flutter/material.dart';

import '../../../../../../models/applicant/applicant_model.dart';

class ApplicantStatsCard extends StatelessWidget {
  final ApplicantModel applicant;

  const ApplicantStatsCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Profile Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Applications',
                  applicant.totalApplications.toString(),
                  Icons.assignment_turned_in,
                  Colors.blue,
                  'Total applications submitted',
                ),
                _buildStatCard(
                  'Active Applications',
                  applicant.activeApplications.toString(),
                  Icons.assignment,
                  Colors.green,
                  'Currently active applications',
                ),
                _buildStatCard(
                  'Profile Views',
                  applicant.profileViews.toString(),
                  Icons.remove_red_eye,
                  Colors.amber,
                  'Times your profile was viewed',
                ),
                _buildStatCard(
                  'Profile Completion',
                  '${applicant.profileCompletion.toInt()}%',
                  applicant.isProfileComplete ? Icons.check_circle : Icons.trending_up,
                  applicant.isProfileComplete ? Colors.green : Colors.orange,
                  applicant.isProfileComplete ? 'Profile complete!' : 'Complete your profile',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  'Education',
                  applicant.education.length.toString(),
                  Icons.school,
                ),
                _buildMiniStat(
                  'Experience',
                  applicant.workExperience.length.toString(),
                  Icons.work,
                ),
                _buildMiniStat(
                  'Skills',
                  applicant.skills.length.toString(),
                  Icons.star,
                ),
                _buildMiniStat(
                  'Documents',
                  applicant.documents.length.toString(),
                  Icons.folder,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
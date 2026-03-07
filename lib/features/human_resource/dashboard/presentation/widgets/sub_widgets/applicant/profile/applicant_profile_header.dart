import 'package:flutter/material.dart';
import '../../../../../../models/applicant/applicant_model.dart';

class ApplicantProfileHeader extends StatelessWidget {
  final ApplicantModel applicant;

  const ApplicantProfileHeader({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    applicant.profilePhoto != null && applicant.profilePhoto!.isNotEmpty
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(applicant.profilePhoto!),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        color: Colors.white,
                        onPressed: () {
                          // Handle profile photo upload
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  applicant.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (applicant.headline != null && applicant.headline!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      applicant.headline!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (applicant.city.isNotEmpty)
                      _buildInfoChip(Icons.location_on, applicant.city),
                    if (applicant.industry != null && applicant.industry!.isNotEmpty)
                      _buildInfoChip(Icons.business, applicant.industry!),
                    if (applicant.yearsOfExperience != null)
                      _buildInfoChip(Icons.timeline, '${applicant.yearsOfExperience!.toStringAsFixed(1)} years exp'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem(
                      'Applications',
                      applicant.totalApplications.toString(),
                      Icons.assignment_turned_in,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      'Profile Views',
                      applicant.profileViews.toString(),
                      Icons.remove_red_eye,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      'Completion',
                      '${applicant.profileCompletion.toInt()}%',
                      applicant.isProfileComplete ? Icons.check_circle : Icons.trending_up,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
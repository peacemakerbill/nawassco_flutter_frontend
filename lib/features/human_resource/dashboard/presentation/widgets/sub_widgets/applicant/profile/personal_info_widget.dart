import 'package:flutter/material.dart';
import '../../../../../../models/applicant/applicant_model.dart';

class PersonalInfoWidget extends StatelessWidget {
  final ApplicantModel applicant;
  final VoidCallback onEdit;

  const PersonalInfoWidget({
    super.key,
    required this.applicant,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit Personal Information',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Basic Information Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              children: [
                _buildInfoItem('Full Name', applicant.fullName, Icons.person),
                _buildInfoItem('Email', applicant.email, Icons.email),
                _buildInfoItem('Phone', applicant.phoneNumber, Icons.phone),
                if (applicant.dateOfBirth != null)
                  _buildInfoItem(
                      'Date of Birth', applicant.dateOfBirth!, Icons.cake),
                if (applicant.gender != null)
                  _buildInfoItem('Gender', _formatGender(applicant.gender!),
                      Icons.person_outline),
                if (applicant.nationality != null)
                  _buildInfoItem(
                      'Nationality', applicant.nationality!, Icons.flag),
              ],
            ),

            const SizedBox(height: 16),

            // Address Section
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${applicant.city}, ${applicant.country}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (applicant.postalCode != null)
                        Text(
                          'Postal Code: ${applicant.postalCode!}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Professional Summary
            if (applicant.headline != null || applicant.summary != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Professional Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              if (applicant.headline != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    applicant.headline!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              if (applicant.summary != null)
                Text(
                  applicant.summary!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
            ],

            // Current Employment
            if (applicant.currentPosition != null ||
                applicant.currentEmployer != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Current Employment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              if (applicant.currentPosition != null)
                _buildInfoRow('Position', applicant.currentPosition!),
              if (applicant.currentEmployer != null)
                _buildInfoRow('Employer', applicant.currentEmployer!),
              if (applicant.industry != null)
                _buildInfoRow('Industry', applicant.industry!),
              if (applicant.yearsOfExperience != null)
                _buildInfoRow('Experience',
                    '${applicant.yearsOfExperience!.toStringAsFixed(1)} years'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGender(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'non_binary':
        return 'Non-binary';
      case 'prefer_not_to_say':
        return 'Prefer not to say';
      case 'other':
        return 'Other';
      default:
        return gender;
    }
  }
}

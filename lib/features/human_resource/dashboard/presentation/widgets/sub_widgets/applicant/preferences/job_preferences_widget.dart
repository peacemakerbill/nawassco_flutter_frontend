import 'package:flutter/material.dart';
import '../../../../../../models/applicant/applicant_model.dart';

class JobPreferencesWidget extends StatelessWidget {
  final JobPreferences? preferences;
  final bool isLoading;
  final VoidCallback onEdit;

  const JobPreferencesWidget({
    super.key,
    this.preferences,
    required this.isLoading,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasPreferences = preferences != null &&
        (preferences!.preferredJobTypes.isNotEmpty ||
            preferences!.preferredLocations.isNotEmpty ||
            preferences!.preferredIndustries.isNotEmpty);

    return Scaffold(
      body: !hasPreferences
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Job Preferences Set',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set your job preferences to help us find the right opportunities for you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.settings),
                    label: const Text('Set Preferences'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.work, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Job Preferences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: onEdit,
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Job Types
                          if (preferences!.preferredJobTypes.isNotEmpty) ...[
                            _buildSectionTitle('Preferred Job Types'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.preferredJobTypes
                                  .map((type) => Chip(
                                        label: Text(
                                          type
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.blue[50],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Position Types
                          if (preferences!
                              .preferredPositionTypes.isNotEmpty) ...[
                            _buildSectionTitle('Preferred Position Types'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.preferredPositionTypes
                                  .map((type) => Chip(
                                        label: Text(
                                          type
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.green[50],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Work Modes
                          if (preferences!.preferredWorkModes.isNotEmpty) ...[
                            _buildSectionTitle('Preferred Work Modes'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.preferredWorkModes
                                  .map((mode) => Chip(
                                        label: Text(
                                          mode
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.orange[50],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Locations
                          if (preferences!.preferredLocations.isNotEmpty) ...[
                            _buildSectionTitle('Preferred Locations'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.preferredLocations
                                  .map((location) => Chip(
                                        label: Text(location),
                                        avatar: const Icon(Icons.location_on,
                                            size: 16),
                                        backgroundColor: Colors.purple[50],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Industries
                          if (preferences!.preferredIndustries.isNotEmpty) ...[
                            _buildSectionTitle('Preferred Industries'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.preferredIndustries
                                  .map((industry) => Chip(
                                        label: Text(industry),
                                        backgroundColor: Colors.teal[50],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Preferences Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 12,
                            children: [
                              _buildPreferenceItem(
                                'Remote Only',
                                preferences!.remoteOnly ? 'Yes' : 'No',
                                Icons.home,
                                preferences!.remoteOnly
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              _buildPreferenceItem(
                                'Visa Sponsorship',
                                preferences!.visaSponsorshipRequired
                                    ? 'Required'
                                    : 'Not Required',
                                Icons.flag,
                                preferences!.visaSponsorshipRequired
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              _buildPreferenceItem(
                                'Relocation',
                                preferences!.willingToRelocate
                                    ? 'Willing'
                                    : 'Not Willing',
                                Icons.public,
                                preferences!.willingToRelocate
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              _buildPreferenceItem(
                                'Notice Period',
                                '${preferences!.noticePeriod} days',
                                Icons.timer,
                                Colors.purple,
                              ),
                            ],
                          ),

                          // Salary Expectations
                          if (preferences!.minimumSalary != null) ...[
                            const SizedBox(height: 16),
                            _buildSectionTitle('Salary Expectations'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.amber[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Minimum Expected Salary',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${preferences!.currency} ${preferences!.minimumSalary!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Available From
                          if (preferences!.availableFrom != null) ...[
                            const SizedBox(height: 16),
                            _buildSectionTitle('Available From'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.green[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Available Start Date',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          _formatDate(
                                              preferences!.availableFrom!),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Relocation Locations
                          if (preferences!.relocationLocations != null &&
                              preferences!.relocationLocations!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSectionTitle('Relocation Locations'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: preferences!.relocationLocations!
                                  .map((location) => Chip(
                                        label: Text(location),
                                        avatar: const Icon(Icons.flight_takeoff,
                                            size: 16),
                                        backgroundColor: Colors.blue[50],
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: onEdit,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildPreferenceItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

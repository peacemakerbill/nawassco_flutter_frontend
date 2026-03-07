import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/field_technician.dart';
import '../../../../providers/field_technician_provider.dart';
import 'edit_technician_dialog.dart';

class TechnicianDetailsDialog extends ConsumerWidget {
  final FieldTechnician technician;

  const TechnicianDetailsDialog({super.key, required this.technician});

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditTechnicianDialog(technician: technician),
    );
  }

  void _updateStatus(
      BuildContext context, WidgetRef ref, TechnicianStatus newStatus) {
    ref
        .read(fieldTechnicianProvider.notifier)
        .updateTechnicianStatus(technician.id, newStatus);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: technician.profilePictureUrl != null
                        ? NetworkImage(technician.profilePictureUrl!)
                        : null,
                    child: technician.profilePictureUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technician.jobTitle.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          technician.employeeNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditDialog(context),
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Section
              _buildSection(
                'Current Status',
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: technician.currentStatus.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: technician.currentStatus.color),
                      ),
                      child: Row(
                        children: [
                          Icon(technician.currentStatus.icon,
                              color: technician.currentStatus.color, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            technician.currentStatus.displayName,
                            style: TextStyle(
                              color: technician.currentStatus.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<TechnicianStatus>(
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      onSelected: (status) =>
                          _updateStatus(context, ref, status),
                      itemBuilder: (context) =>
                          TechnicianStatus.values.map((status) {
                        return PopupMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(status.icon, color: status.color, size: 16),
                              const SizedBox(width: 8),
                              Text(status.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Contact Information
              _buildSection(
                'Contact Information',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        Icons.email_rounded, 'Email', technician.email),
                    _buildInfoRow(
                        Icons.phone_rounded, 'Phone', technician.phone),
                    if (technician.dateOfBirth != null)
                      _buildInfoRow(
                        Icons.cake_rounded,
                        'Date of Birth',
                        '${technician.dateOfBirth!.day}/${technician.dateOfBirth!.month}/${technician.dateOfBirth!.year}',
                      ),
                    _buildInfoRow(Icons.badge_rounded, 'National ID',
                        technician.nationalId),
                  ],
                ),
              ),

              // Work Information
              _buildSection(
                'Work Information',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.work_rounded, 'Department',
                        technician.department),
                    _buildInfoRow(Icons.location_on_rounded, 'Work Zone',
                        technician.workZone),
                    _buildInfoRow(Icons.calendar_today_rounded, 'Hire Date',
                        '${technician.hireDate.day}/${technician.hireDate.month}/${technician.hireDate.year}'),
                    if (technician.vehicleAssigned != null)
                      _buildInfoRow(Icons.directions_car_rounded, 'Vehicle',
                          technician.vehicleAssigned!),
                  ],
                ),
              ),

              // Performance Metrics
              _buildSection(
                'Performance Metrics',
                Column(
                  children: [
                    _buildPerformanceMetric(
                        'Jobs Completed',
                        '${technician.jobsCompleted}',
                        Icons.assignment_turned_in_rounded),
                    _buildPerformanceMetric(
                        'On-Time Completion',
                        '${technician.onTimeCompletionRate.toStringAsFixed(1)}%',
                        Icons.timer_rounded),
                    _buildPerformanceMetric(
                        'Customer Satisfaction',
                        '${technician.customerSatisfaction.toStringAsFixed(1)}%',
                        Icons.star_rounded),
                    _buildPerformanceMetric(
                        'First-Time Fix Rate',
                        '${technician.firstTimeFixRate.toStringAsFixed(1)}%',
                        Icons.build_rounded),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: technician.performanceScore / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: technician.performanceColor,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Performance',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${technician.performanceScore.toStringAsFixed(1)}% - ${technician.performanceLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: technician.performanceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Specializations
              if (technician.specializedAreas.isNotEmpty)
                _buildSection(
                  'Specialized Areas',
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: technician.specializedAreas.map((area) {
                      return Chip(
                        label: Text(area),
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        labelStyle: TextStyle(color: theme.colorScheme.primary),
                      );
                    }).toList(),
                  ),
                ),

              // Assigned Regions
              if (technician.assignedRegions.isNotEmpty)
                _buildSection(
                  'Assigned Regions',
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: technician.assignedRegions.map((region) {
                      return Chip(
                        label: Text(region),
                        backgroundColor:
                            theme.colorScheme.secondary.withOpacity(0.1),
                        labelStyle:
                            TextStyle(color: theme.colorScheme.secondary),
                      );
                    }).toList(),
                  ),
                ),

              // Tools Assigned
              if (technician.toolsAssigned.isNotEmpty)
                _buildSection(
                  'Tools Assigned',
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: technician.toolsAssigned.map((tool) {
                      return Chip(
                        label: Text(tool),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.orange),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showEditDialog(context),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class TrainingCard extends ConsumerWidget {
  final Training training;
  final bool showActions;
  final VoidCallback? onTap;

  const TrainingCard({
    super.key,
    required this.training,
    this.showActions = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.read(trainingProvider.notifier).canManageTrainings;
    final isRegistered = training.isRegistered;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 80,
                    decoration: BoxDecoration(
                      color: training.statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                training.trainingTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Chip(
                              label: Text(
                                training.trainingCode,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.blue.shade700,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          training.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Quick info row
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              icon: Icons.category,
                              text: training.categoryText,
                              color: Colors.blue.shade100,
                            ),
                            _buildInfoChip(
                              icon: Icons.school,
                              text: training.levelText,
                              color: Colors.green.shade100,
                            ),
                            _buildInfoChip(
                              icon: Icons.schedule,
                              text: training.durationText,
                              color: Colors.orange.shade100,
                            ),
                            _buildInfoChip(
                              icon: Icons.people,
                              text:
                                  '${training.totalParticipants}/${training.maxParticipants}',
                              color: training.availableSlots > 0
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Dates and venue
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${DateFormat('dd MMM').format(training.startDate)} - ${DateFormat('dd MMM yyyy').format(training.endDate)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                training.venue,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Progress bar for registration
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Registration Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${training.totalParticipants}/${training.maxParticipants}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: training.progressPercentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: training.availableSlots > 0
                                  ? Colors.green
                                  : Colors.red,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              training.availableSlots > 0
                                  ? '${training.availableSlots} slots available'
                                  : 'Fully booked',
                              style: TextStyle(
                                fontSize: 11,
                                color: training.availableSlots > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Actions
                        if (showActions)
                          _buildActionButtons(
                              context, ref, canManage, isRegistered),
                      ],
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

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, bool canManage, bool isRegistered) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Details'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              backgroundColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!canManage && training.isOpenForRegistration && !isRegistered)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(trainingProvider.notifier)
                    .registerForTraining(training.id);
              },
              icon: const Icon(Icons.app_registration, size: 18),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (isRegistered)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Registered',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (canManage)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Show management options
                _showManagementOptions(context, ref);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Manage'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showManagementOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Training'),
                onTap: () {
                  Navigator.pop(context);
                  // This will be handled by the parent widget
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.green),
                title: const Text('Manage Participants'),
                onTap: () {
                  Navigator.pop(context);
                  // This will be handled by the parent widget
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.purple),
                title: const Text('Upload Materials'),
                onTap: () {
                  Navigator.pop(context);
                  // This will be handled by the parent widget
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Training'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Training'),
          content: const Text(
              'Are you sure you want to delete this training? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(trainingProvider.notifier).deleteTraining(training.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

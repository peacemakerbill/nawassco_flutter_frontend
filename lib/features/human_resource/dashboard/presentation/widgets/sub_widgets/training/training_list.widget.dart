import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';
import 'status_badge.widget.dart';

class TrainingList extends ConsumerWidget {
  final List<Training> trainings;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(Training) onTrainingSelect;
  final Function(Training)? onTrainingEdit;
  final Function(Training)? onTrainingDelete;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool showManagementActions;
  final String emptyMessage;

  const TrainingList({
    super.key,
    required this.trainings,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.onTrainingSelect,
    this.onTrainingEdit,
    this.onTrainingDelete,
    required this.onLoadMore,
    required this.hasMore,
    this.showManagementActions = false,
    this.emptyMessage = 'No trainings found',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trainingProvider);

    // Show loading state
    if (isLoading && trainings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading trainings...'),
          ],
        ),
      );
    }

    // Show error state
    if (error != null && trainings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (trainings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showManagementActions ? Icons.school_outlined : Icons.bookmark_border,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              showManagementActions
                  ? 'Create your first training program'
                  : 'Check back later for upcoming trainings',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (showManagementActions)
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trainings.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= trainings.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More Trainings'),
                ),
              ),
            );
          }

          final training = trainings[index];
          return TrainingListItem(
            training: training,
            onSelect: () => onTrainingSelect(training),
            onEdit: showManagementActions && onTrainingEdit != null
                ? () => onTrainingEdit!(training)
                : null,
            onDelete: showManagementActions && onTrainingDelete != null
                ? () => onTrainingDelete!(training)
                : null,
            showManagementActions: showManagementActions,
            onRegister: !showManagementActions && training.isOpenForRegistration && !training.isRegistered
                ? () => _handleRegister(training, ref)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleRegister(Training training, WidgetRef ref) async {
    final success = await ref.read(trainingProvider.notifier).registerForTraining(training.id);
    if (success) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for "${training.trainingTitle}"'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class TrainingListItem extends StatelessWidget {
  final Training training;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRegister;
  final bool showManagementActions;

  const TrainingListItem({
    super.key,
    required this.training,
    required this.onSelect,
    this.onEdit,
    this.onDelete,
    this.onRegister,
    this.showManagementActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  StatusBadge(status: training.status),
                  const SizedBox(width: 12),

                  // Title and code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          training.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quick info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: training.categoryText,
                    color: Colors.blue.shade100,
                  ),
                  _buildInfoChip(
                    icon: Icons.school,
                    label: training.levelText,
                    color: Colors.green.shade100,
                  ),
                  _buildInfoChip(
                    icon: Icons.type_specimen,
                    label: training.typeText,
                    color: Colors.orange.shade100,
                  ),
                  _buildInfoChip(
                    icon: Icons.people,
                    label: '${training.totalParticipants}/${training.maxParticipants}',
                    color: training.availableSlots > 0
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),
                  if (training.cost > 0)
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      label: '${training.currency} ${training.cost.toStringAsFixed(0)}',
                      color: Colors.purple.shade100,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Dates and venue
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
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
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
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

              // Progress bar
              _buildProgressBar(),

              const SizedBox(height: 12),

              // Status and registration info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: training.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      training.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: training.statusColor,
                      ),
                    ),
                  ),

                  if (training.isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Registered',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (training.isOpenForRegistration && !training.isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Open for Registration',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (training.availableSlots == 0 && training.status != TrainingStatus.completed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_off, size: 14, color: Colors.red.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Fully Booked',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
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
          color: _getProgressColor(),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              training.availableSlots > 0
                  ? '${training.availableSlots} slots available'
                  : 'Fully booked',
              style: TextStyle(
                fontSize: 11,
                color: training.availableSlots > 0 ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            if (training.registrationDeadline.isAfter(DateTime.now()))
              Row(
                children: [
                  Icon(Icons.access_time, size: 11, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Closes ${DateFormat('dd MMM').format(training.registrationDeadline)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // View button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue.shade200),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Register button (for employees)
        if (onRegister != null && !showManagementActions)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRegister,
              icon: const Icon(Icons.app_registration, size: 18),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade600,
              ),
            ),
          ),

        // Edit button (for managers)
        if (showManagementActions && onEdit != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange.shade600,
              ),
            ),
          ),

        const SizedBox(width: 8),

        // Delete button (for managers)
        if (showManagementActions && onDelete != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Color _getProgressColor() {
    if (training.availableSlots > training.maxParticipants * 0.5) {
      return Colors.green;
    } else if (training.availableSlots > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// Compact version for dashboards and small spaces
class TrainingListCompact extends StatelessWidget {
  final List<Training> trainings;
  final Function(Training) onTrainingSelect;
  final int maxItems;

  const TrainingListCompact({
    super.key,
    required this.trainings,
    required this.onTrainingSelect,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayedTrainings = trainings.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trainings.isNotEmpty)
          ...displayedTrainings.map((training) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCompactItem(training, context),
            );
          }).toList(),

        if (trainings.length > maxItems)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to full list
                },
                child: const Text('View All Trainings →'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactItem(Training training, BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onTrainingSelect(training),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: training.statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // Training info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      training.trainingTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM').format(training.startDate),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${training.totalParticipants}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: training.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  training.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: training.statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/consultancy_model.dart';

class ConsultancyCard extends StatelessWidget {
  final Consultancy consultancy;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ConsultancyCard({
    super.key,
    required this.consultancy,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with number and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      consultancy.consultancyNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: consultancy.status.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: consultancy.status.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          consultancy.status.statusIcon,
                          size: 14,
                          color: consultancy.status.statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          consultancy.status.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: consultancy.status.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                consultancy.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Category and Client
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      consultancy.category.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Client: ${consultancy.client.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description (collapsed)
              Text(
                consultancy.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Progress and timeline
              _buildTimelineInfo(context),

              const SizedBox(height: 12),

              // Footer with budget and actions
              Row(
                children: [
                  // Budget
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'KES ${NumberFormat('#,##0').format(consultancy.budget.totalAmount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions (if enabled)
                  if (showActions) ...[
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 20),
                        color: colorScheme.primary,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 20),
                        color: colorScheme.error,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete',
                      ),
                  ],

                  // View details arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.disabledColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineInfo(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isActive = consultancy.status == ConsultancyStatus.ACTIVE;
    final progress = consultancy.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        if (isActive)
          Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    '${consultancy.timeline.endDate.difference(now).inDays} days left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${consultancy.formattedStartDate} - ${consultancy.formattedEndDate}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

        const SizedBox(height: 8),

        // Milestones count
        if (consultancy.milestones.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.flag,
                size: 16,
                color: Colors.orange[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${consultancy.milestones.length} milestones',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.people,
                size: 16,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${consultancy.team.length} team members',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
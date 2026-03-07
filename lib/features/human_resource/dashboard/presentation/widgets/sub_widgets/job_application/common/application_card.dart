import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';
import 'stage_progress_indicator.dart';
import 'status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final bool showJobDetails;
  final bool showApplicantDetails;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;
  final VoidCallback? onViewDetails;
  final bool isSelected;

  const ApplicationCard({
    super.key,
    required this.application,
    this.showJobDetails = true,
    this.showApplicantDetails = false,
    this.showActions = true,
    this.onTap,
    this.onWithdraw,
    this.onViewDetails,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Application Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicationNumber,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (showJobDetails && application.jobDetails != null)
                          Text(
                            application.jobDetails!.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  StatusBadge(status: application.status),
                ],
              ),

              const SizedBox(height: 12),

              // Applicant Details
              if (showApplicantDetails) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        application.applicant.fullName
                            .split(' ')
                            .map((n) => n.isNotEmpty ? n[0] : '')
                            .join()
                            .toUpperCase()
                            .substring(0, 2),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.applicant.fullName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            application.applicant.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Progress Indicator
              StageProgressIndicator(
                currentStage: application.currentStage,
                totalStages: 8,
                stageHistory: application.stageHistory,
                height: 60,
                indicatorSize: 24,
                showLabels: false,
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    context,
                    Icons.calendar_today,
                    _formatDate(application.applicationDate),
                  ),
                  _buildDetailItem(
                    context,
                    Icons.timelapse,
                    application.timeInCurrentStatus,
                  ),
                  _buildDetailItem(
                    context,
                    Icons.star,
                    '${application.overallRating.toStringAsFixed(1)}/5',
                  ),
                ],
              ),

              // Actions
              if (showActions) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.remove_red_eye_outlined),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (application.canWithdraw)
                      OutlinedButton(
                        onPressed: onWithdraw,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          foregroundColor: Colors.red,
                          side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.5)),
                        ),
                        child: const Text('Withdraw'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

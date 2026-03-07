import 'package:flutter/material.dart';

import '../../../../../../models/job_application_model.dart';
import 'stage_progress_indicator.dart';
import 'status_badge.dart';

class ApplicationDetailsCard extends StatelessWidget {
  final JobApplication application;
  final bool showFullDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onScheduleInterview;
  final VoidCallback? onAddReview;
  final bool isHRView;

  const ApplicationDetailsCard({
    super.key,
    required this.application,
    this.showFullDetails = true,
    this.onEdit,
    this.onWithdraw,
    this.onScheduleInterview,
    this.onAddReview,
    this.isHRView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicationNumber,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (application.jobDetails != null)
                      Text(
                        application.jobDetails!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                StatusBadge(
                  status: application.status,
                  size: 12,
                  dense: false,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Section
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StageProgressIndicator(
                      currentStage: application.currentStage,
                      totalStages: 8,
                      stageHistory: application.stageHistory,
                      showLabels: true,
                      showDates: true,
                    ),
                    const SizedBox(height: 8),
                    Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          context,
                          'Applied On',
                          _formatDate(application.applicationDate),
                          Icons.calendar_today,
                        ),
                        _buildStatItem(
                          context,
                          'Time in Status',
                          application.timeInCurrentStatus,
                          Icons.timelapse,
                        ),
                        _buildStatItem(
                          context,
                          'Rating',
                          '${application.overallRating.toStringAsFixed(1)}/5',
                          Icons.star,
                        ),
                        _buildStatItem(
                          context,
                          'Views',
                          '${application.viewedCount}',
                          Icons.remove_red_eye,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Applicant Details
            if (showFullDetails) ...[
              Text(
                'Applicant Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          application.applicant.fullName
                              .split(' ')
                              .map((n) => n.isNotEmpty ? n[0] : '')
                              .join()
                              .toUpperCase()
                              .substring(0, 2),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.applicant.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              application.applicant.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(
                                  context,
                                  Icons.phone,
                                  application.applicant.phoneNumber,
                                ),
                                if (application.applicant.location != null)
                                  _buildInfoChip(
                                    context,
                                    Icons.location_on,
                                    application.applicant.location!,
                                  ),
                                if (application.applicant.currentPosition !=
                                    null)
                                  _buildInfoChip(
                                    context,
                                    Icons.work,
                                    application.applicant.currentPosition!,
                                  ),
                                if (application.applicant.yearsOfExperience !=
                                    null)
                                  _buildInfoChip(
                                    context,
                                    Icons.timeline,
                                    '${application.applicant.yearsOfExperience!.toStringAsFixed(1)} yrs exp',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Custom Cover Letter
            if (application.customCoverLetter != null &&
                application.customCoverLetter!.isNotEmpty) ...[
              Text(
                'Cover Letter',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    application.customCoverLetter!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Documents Section
            if (application.selectedDocuments.isNotEmpty) ...[
              Text(
                'Documents',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: application.selectedDocuments
                    .map((doc) => _buildDocumentChip(context, doc))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Actions Section
            Row(
              children: [
                if (isHRView) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onScheduleInterview,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Interview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAddReview,
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Add Review'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (application.canWithdraw)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onWithdraw,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Withdraw'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.red,
                        side: BorderSide(
                            color: Colors.red.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      side: BorderSide.none,
    );
  }

  Widget _buildDocumentChip(
    BuildContext context,
    ApplicationDocument document,
  ) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(
        _getDocumentIcon(document.type),
        size: 18,
        color: theme.colorScheme.primary,
      ),
      label: Text(
        document.name,
        style: theme.textTheme.labelSmall,
      ),
      onPressed: () {
        // TODO: Open document
      },
      backgroundColor: theme.colorScheme.surfaceVariant,
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'resume':
        return Icons.description;
      case 'cover_letter':
        return Icons.mail_outline;
      case 'portfolio':
        return Icons.folder_open;
      case 'certificate':
        return Icons.verified;
      case 'transcript':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

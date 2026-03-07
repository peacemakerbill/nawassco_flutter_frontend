import 'package:flutter/material.dart';
import '../../../../../../models/performance/performance_appraisal.model.dart';

class AppraisalCard extends StatelessWidget {
  final PerformanceAppraisal appraisal;
  final VoidCallback? onTap;
  final VoidCallback? onReview;
  final VoidCallback? onAcknowledge;
  final bool showActions;

  const AppraisalCard({
    super.key,
    required this.appraisal,
    this.onTap,
    this.onReview,
    this.onAcknowledge,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appraisal.appraisalNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appraisal.employeeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: appraisal.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: appraisal.status.color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          appraisal.status.icon,
                          size: 14,
                          color: appraisal.status.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appraisal.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: appraisal.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: 'Period',
                    value: appraisal.appraisalPeriod,
                  ),
                  _buildDetailItem(
                    icon: Icons.rate_review,
                    label: 'Reviewer',
                    value: appraisal.reviewerName,
                  ),
                  _buildDetailItem(
                    icon: Icons.date_range,
                    label: 'Date',
                    value: _formatDate(appraisal.appraisalDate),
                  ),
                  if (appraisal.nextAppraisalDate.isAfter(DateTime.now()))
                    _buildDetailItem(
                      icon: Icons.next_plan,
                      label: 'Next Review',
                      value: _formatDate(appraisal.nextAppraisalDate),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Rating & Performance
              Row(
                children: [
                  _buildRatingChip(
                    label: 'Overall Rating',
                    value: appraisal.overallRating.toStringAsFixed(1),
                    color: _getRatingColor(appraisal.overallRating),
                  ),
                  const SizedBox(width: 8),
                  _buildRatingChip(
                    label: 'Performance',
                    value: appraisal.performanceLevel.displayName,
                    color: _getPerformanceColor(appraisal.performanceLevel),
                  ),
                  const SizedBox(width: 8),
                  _buildRatingChip(
                    label: 'Potential',
                    value: appraisal.potentialLevel.displayName,
                    color: _getPotentialColor(appraisal.potentialLevel),
                  ),
                ],
              ),

              // Actions
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final actions = <Widget>[];

    if (appraisal.canReview && onReview != null) {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onReview,
            icon: const Icon(Icons.reviews, size: 16),
            label: const Text('Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange,
            ),
          ),
        ),
      );
    }

    if (appraisal.canAcknowledge && onAcknowledge != null) {
      actions.add(
        const SizedBox(width: 8),
      );
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAcknowledge,
            icon: const Icon(Icons.thumb_up, size: 16),
            label: const Text('Acknowledge'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green,
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return Container();
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            child: const Text('View Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue,
            ),
          ),
        ),
        ...actions,
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }

  Color _getPerformanceColor(PerformanceLevel level) {
    return switch (level) {
      PerformanceLevel.exceedsExpectations => Colors.green,
      PerformanceLevel.meetsExpectations => Colors.blue,
      PerformanceLevel.needsImprovement => Colors.orange,
      PerformanceLevel.unsatisfactory => Colors.red,
    };
  }

  Color _getPotentialColor(PotentialLevel level) {
    return switch (level) {
      PotentialLevel.highPotential => Colors.purple,
      PotentialLevel.growthPotential => Colors.blue,
      PotentialLevel.steadyPerformer => Colors.green,
      PotentialLevel.plateaued => Colors.grey,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
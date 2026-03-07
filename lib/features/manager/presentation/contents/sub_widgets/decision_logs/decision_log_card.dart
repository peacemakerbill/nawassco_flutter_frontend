import 'package:flutter/material.dart';
import '../../../../models/decision_log_model.dart';

class DecisionLogCard extends StatelessWidget {
  final DecisionLog decisionLog;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;

  const DecisionLogCard({
    super.key,
    required this.decisionLog,
    required this.onViewDetail,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          decisionLog.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          decisionLog.decisionId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(decisionLog.status),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                decisionLog.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Context chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    'Urgency: ${decisionLog.context.urgency.label}',
                    decisionLog.context.urgency.color,
                  ),
                  _buildChip(
                    'Impact: ${decisionLog.context.impact.label}',
                    decisionLog.context.impact.color,
                  ),
                  _buildChip(
                    '${decisionLog.alternatives.length} Alternatives',
                    Colors.blue,
                  ),
                  if (decisionLog.implementationSteps.isNotEmpty)
                    _buildChip(
                      '${decisionLog.implementationSteps.length} Steps',
                      Colors.purple,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer row
              Row(
                children: [
                  // Decision date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Decided: ${_formatDate(decisionLog.decisionDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          size: 20,
                          color: Colors.blue[600],
                        ),
                        onPressed: onViewDetail,
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.green[600],
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                    ],
                  ),
                ],
              ),

              // Progress indicator for implementation
              if (decisionLog.implementationSteps.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value:
                          _calculateProgress(decisionLog.implementationSteps),
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Implementation Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_calculateProgress(decisionLog.implementationSteps) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DecisionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateProgress(List<ImplementationStep> steps) {
    if (steps.isEmpty) return 0;
    final completed =
        steps.where((s) => s.status == StepStatus.completed).length;
    return completed / steps.length;
  }
}

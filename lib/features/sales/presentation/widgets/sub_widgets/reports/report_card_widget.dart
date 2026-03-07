import 'package:flutter/material.dart';

import '../../../../models/report.model.dart';

class ReportCardWidget extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final bool showActions;

  const ReportCardWidget({
    super.key,
    required this.report,
    required this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
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
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: report.statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      report.statusDisplay,
                      style: TextStyle(
                        color: report.statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Report number and type
              Text(
                '${report.reportNumber} • ${report.reportType.displayName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 12),

              // Key metrics
              Row(
                children: [
                  _buildMetric(
                    icon: Icons.calendar_today,
                    value: _formatDate(report.reportDate),
                    label: 'Date',
                  ),
                  const SizedBox(width: 16),
                  _buildMetric(
                    icon: Icons.person,
                    value: report.authorName ?? 'Unknown',
                    label: 'Author',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildMetric(
                    icon: Icons.attach_money,
                    value: 'KES ${report.salesValue.toStringAsFixed(2)}',
                    label: 'Sales',
                  ),
                  const SizedBox(width: 16),
                  _buildMetric(
                    icon: Icons.trending_up,
                    value: '${report.conversionRate.toStringAsFixed(1)}%',
                    label: 'Conversion',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Footer with actions
              if (showActions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(report.updatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      children: [
                        if (report.canEdit)
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            onPressed: onTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.visibility,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onPressed: onTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
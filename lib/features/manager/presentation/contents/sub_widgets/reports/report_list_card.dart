import 'package:flutter/material.dart';
import '../../../../models/reports/management_report_model.dart';
import 'report_status_chip.dart';

class ReportListCard extends StatelessWidget {
  final ManagementReport report;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReportListCard({
    super.key,
    required this.report,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 1,
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
              Row(
                children: [
                  Icon(
                    report.type.icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ReportStatusChip(status: report.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.executiveSummary ?? 'No summary available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today,
                    report.formattedStartDate,
                    context,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.repeat,
                    report.frequency.displayName,
                    context,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.person,
                    report.preparedByName ?? 'Unknown',
                    context,
                  ),
                  const Spacer(),
                  if (report.isEditable && onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit,
                          size: 20, color: Colors.grey.shade600),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete,
                          size: 20, color: Colors.grey.shade600),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

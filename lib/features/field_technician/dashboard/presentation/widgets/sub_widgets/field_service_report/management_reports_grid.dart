import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/field_service_report_model.dart';

class ManagementReportsGrid extends StatelessWidget {
  final List<FieldServiceReport> reports;
  final List<String> selectedReportIds;
  final Function(String) onToggleSelection;
  final Function(FieldServiceReport) onViewDetails;
  final Function(String, FieldServiceReport) onReportAction;

  const ManagementReportsGrid({
    super.key,
    required this.reports,
    required this.selectedReportIds,
    required this.onToggleSelection,
    required this.onViewDetails,
    required this.onReportAction,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final isSelected = selectedReportIds.contains(report.id);

        return GestureDetector(
          onTap: () => onViewDetails(report),
          onLongPress: () => onToggleSelection(report.id),
          child: ManagementReportGridCard(
            report: report,
            isSelected: isSelected,
            onToggleSelection: () => onToggleSelection(report.id),
            onReportAction: (action) => onReportAction(action, report),
          ),
        );
      },
    );
  }
}

class ManagementReportGridCard extends StatelessWidget {
  final FieldServiceReport report;
  final bool isSelected;
  final Function() onToggleSelection;
  final Function(String) onReportAction;

  const ManagementReportGridCard({
    super.key,
    required this.report,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onReportAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onToggleSelection(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                _buildStatusBadge(),

                const SizedBox(height: 8),

                Text(
                  report.reportNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  report.workOrderTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Technician
                _buildDetailRow(Icons.person, report.technicianName),

                const SizedBox(height: 4),

                // Date & Time
                _buildDetailRow(
                  Icons.calendar_today,
                  DateFormat('MMM dd, yyyy').format(report.serviceDate),
                ),

                const Spacer(),

                // Stats Row
                _buildStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor(report.approvalStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        report.approvalStatus.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatColumn('${report.tasksCompleted.length}', 'Tasks'),
        _buildStatColumn('\$${report.totalMaterialCost.toStringAsFixed(0)}', 'Cost'),
        _buildRatingColumn(),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingColumn() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                '${report.customerSatisfaction}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Rating',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    return switch (status) {
      ApprovalStatus.pending => Colors.orange,
      ApprovalStatus.approved => Colors.green,
      ApprovalStatus.rejected => Colors.red,
      ApprovalStatus.revised => Colors.blue,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/field_service_report_model.dart';

class ManagementReportsList extends StatelessWidget {
  final List<FieldServiceReport> reports;
  final AuthState authState;
  final List<String> selectedReportIds;
  final Function(String) onToggleSelection;
  final Function(FieldServiceReport) onViewDetails;
  final Function(String, FieldServiceReport) onReportAction;

  const ManagementReportsList({
    super.key,
    required this.reports,
    required this.authState,
    required this.selectedReportIds,
    required this.onToggleSelection,
    required this.onViewDetails,
    required this.onReportAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final isSelected = selectedReportIds.contains(report.id);

        return ManagementReportListItem(
          report: report,
          authState: authState,
          isSelected: isSelected,
          onToggleSelection: () => onToggleSelection(report.id),
          onViewDetails: () => onViewDetails(report),
          onReportAction: (action) => onReportAction(action, report),
        );
      },
    );
  }
}

class ManagementReportListItem extends StatelessWidget {
  final FieldServiceReport report;
  final AuthState authState;
  final bool isSelected;
  final Function() onToggleSelection;
  final Function() onViewDetails;
  final Function(String) onReportAction;

  const ManagementReportListItem({
    super.key,
    required this.report,
    required this.authState,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onViewDetails,
    required this.onReportAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onViewDetails,
        onLongPress: onToggleSelection,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection(),
              ),

              const SizedBox(width: 12),

              // Status Indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(report.approvalStatus),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              // Report Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.reportNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      report.workOrderTitle,
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),

                    // Details Row
                    _buildDetailsRow(),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Menu
              ManagementReportActionMenu(
                report: report,
                authState: authState,
                onActionSelected: onReportAction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor(report.approvalStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildDetailsRow() {
    return Row(
      children: [
        Expanded(child: _buildDetail('Technician', report.technicianName)),
        Expanded(
            child: _buildDetail(
                'Date', DateFormat('MMM dd, yyyy').format(report.serviceDate))),
        Expanded(
            child: _buildDetail('Tasks', '${report.tasksCompleted.length}')),
        Expanded(
            child: _buildDetail(
                'Cost', '\$${report.totalMaterialCost.toStringAsFixed(2)}')),
        Expanded(child: _buildRating()),
      ],
    );
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text('${report.customerSatisfaction}/5'),
      ],
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

class ManagementReportActionMenu extends StatelessWidget {
  final FieldServiceReport report;
  final AuthState authState;
  final Function(String)? onActionSelected;

  const ManagementReportActionMenu({
    super.key,
    required this.report,
    required this.authState,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (value) {
        onActionSelected?.call(value);
      },
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    items.add(
      const PopupMenuItem<String>(
        value: 'view',
        child: ListTile(
          leading: Icon(Icons.visibility),
          title: Text('View Details'),
        ),
      ),
    );

    if (report.canApprove) {
      items.add(
        const PopupMenuItem<String>(
          value: 'approve',
          child: ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Approve'),
          ),
        ),
      );
    }

    if (report.canApprove) {
      items.add(
        const PopupMenuItem<String>(
          value: 'reject',
          child: ListTile(
            leading: Icon(Icons.cancel),
            title: Text('Reject'),
          ),
        ),
      );
    }

    items.add(
      const PopupMenuItem<String>(
        value: 'pdf',
        child: ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text('Generate PDF'),
        ),
      ),
    );

    return items;
  }
}

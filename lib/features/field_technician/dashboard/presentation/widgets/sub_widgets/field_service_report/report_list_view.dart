import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/field_service_report_model.dart';
import '../../../../providers/field_service_report_provider.dart';
import 'report_action_menu.dart';
import 'report_detail_widget.dart';

class ReportListView extends ConsumerWidget {
  final List<FieldServiceReport> reports;
  final AuthState authState;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const ReportListView({
    super.key,
    required this.reports,
    required this.authState,
    this.scrollController,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: reports.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (hasMore && index == reports.length) {
          return _buildLoadMore(ref);
        }

        final report = reports[index];
        return ReportCard(
          report: report,
          authState: authState,
          onTap: () => _showReportDetails(context, ref, report),
        );
      },
    );
  }

  Widget _buildLoadMore(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onLoadMore,
                child: const Text('Load More Reports'),
              ),
      ),
    );
  }

  void _showReportDetails(
      BuildContext context, WidgetRef ref, FieldServiceReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReportDetailWidget(
        report: report,
        authState: authState,
        onReportUpdated: () {
          ref.read(fieldServiceReportProvider.notifier).refreshReports();
        },
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final FieldServiceReport report;
  final AuthState authState;
  final VoidCallback? onTap;
  final Function(String, FieldServiceReport)? onActionSelected;

  const ReportCard({
    super.key,
    required this.report,
    required this.authState,
    this.onTap,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              // Status and Actions Row
              Row(
                children: [
                  _buildStatusBadge(report.approvalStatus),
                  const Spacer(),
                  _buildActionMenu(context),
                ],
              ),

              const SizedBox(height: 12),

              // Report Info
              _buildReportInfo(),

              const SizedBox(height: 12),

              // Details Row
              _buildDetailsRow(),

              const SizedBox(height: 12),

              // Progress Indicators
              _buildProgressIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApprovalStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return ReportActionMenu(
      report: report,
      authState: authState,
      onActionSelected: (action) {
        onActionSelected?.call(action, report);
      },
    );
  }

  Widget _buildReportInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.reportNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          report.workOrderTitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailColumn(
            title: 'Technician',
            value: report.technicianName,
          ),
        ),
        Expanded(
          child: _buildDetailColumn(
            title: 'Service Date',
            value: DateFormat('MMM dd, yyyy').format(report.serviceDate),
          ),
        ),
        Expanded(
          child: _buildDetailColumn(
            title: 'Customer Rating',
            valueWidget: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${report.customerSatisfaction}/5',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailColumn({
    required String title,
    String? value,
    Widget? valueWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        valueWidget ??
            Text(
              value ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tasks Completion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: report.tasksCompleted.isEmpty
                    ? 0
                    : report.completedTasksCount / report.tasksCompleted.length,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
              Text(
                '${report.completedTasksCount}/${report.tasksCompleted.length} tasks',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (report.totalMaterialCost > 0) ...[
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Material Cost',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${report.totalMaterialCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/reports/management_report_model.dart';
import '../../../../providers/management_report_provider.dart';
import 'report_status_chip.dart';
import 'feedback_item.dart';
import 'action_item_card.dart';
import 'workflow_action_buttons.dart';

class ReportDetailSheet extends ConsumerWidget {
  final ManagementReport report;
  final VoidCallback onClose;

  const ReportDetailSheet({
    super.key,
    required this.report,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.75, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          report.type.icon,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ReportStatusChip(status: report.status, large: true),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.repeat,
                          report.frequency.displayName,
                          context,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.security,
                          report.confidentiality.displayName,
                          context,
                          color: report.confidentiality.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    WorkflowActionButtons(report: report),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Sections'),
                            Tab(text: 'Feedback'),
                            Tab(text: 'Actions'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildOverviewTab(context),
                            _buildSectionsTab(),
                            _buildFeedbackTab(),
                            _buildActionsTab(ref),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, BuildContext context,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.executiveSummary != null) ...[
            const Text(
              'Executive Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.executiveSummary!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Report Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            'Prepared By',
            '${report.preparedByName ?? "Unknown"}${report.preparedByTitle != null ? " • ${report.preparedByTitle}" : ""}',
            Icons.person,
          ),
          _buildDetailItem(
            'Review Status',
            report.status.displayName,
            report.status.icon,
          ),
          if (report.reviewedByName != null)
            _buildDetailItem(
              'Reviewed By',
              report.reviewedByName!,
              Icons.verified_user,
            ),
          if (report.approvedByName != null)
            _buildDetailItem(
              'Approved By',
              report.approvedByName!,
              Icons.check_circle,
            ),
          _buildDetailItem(
            'Start Date',
            report.formattedStartDate,
            Icons.calendar_today,
          ),
          if (report.endDate != null)
            _buildDetailItem(
              'End Date',
              report.formattedEndDate,
              Icons.calendar_today,
            ),
          if (report.approvalDate != null)
            _buildDetailItem(
              'Approval Date',
              report.formattedApprovalDate,
              Icons.event_available,
            ),
          _buildDetailItem(
            'Created',
            report.formattedCreatedAt,
            Icons.schedule,
          ),
          const SizedBox(height: 24),
          if (report.distributionList.isNotEmpty) ...[
            const Text(
              'Distribution List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.distributionList.map((dist) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      dist.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: Text(dist.name),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: report.sections.length,
      itemBuilder: (context, index) {
        final section = report.sections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTab() {
    if (report.feedback.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No feedback yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: report.feedback.length,
      itemBuilder: (context, index) {
        return FeedbackItem(feedback: report.feedback[index]);
      },
    );
  }

  Widget _buildActionsTab(WidgetRef ref) {
    if (report.actionItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No action items',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: report.actionItems.length,
      itemBuilder: (context, index) {
        return ActionItemCard(
          actionItem: report.actionItems[index],
          onStatusChange: (status) {
            ref.read(managementReportProvider.notifier).updateActionItemStatus(
                  report.id,
                  report.actionItems[index].id,
                  status,
                );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

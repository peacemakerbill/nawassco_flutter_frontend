import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/report.model.dart';
import '../../../../providers/report_provider.dart';
import 'responsive.dart';

class ReportDetailWidget extends ConsumerWidget {
  final Report report;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmitForReview;
  final VoidCallback? onApprove;
  final Function(String)? onReject;

  const ReportDetailWidget({
    super.key,
    required this.report,
    this.onClose,
    this.onEdit,
    this.onDelete,
    this.onSubmitForReview,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final provider = ref.read(reportProvider.notifier);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      body: Column(
        children: [
          // Dialog Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose ?? () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Report Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isMobile && (report.canEdit || authState.isAdmin || authState.isManager))
                  Row(
                    children: [
                      if (report.canEdit && !report.isSubmitted)
                        ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      if (!report.isSubmitted && report.canEdit)
                        const SizedBox(width: 8),
                      if (!report.isSubmitted && report.canEdit)
                        ElevatedButton.icon(
                          onPressed: onSubmitForReview,
                          icon: const Icon(Icons.send, size: 16),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Title and Status
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                          color: const Color(0xFF1E3A8A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        report.reportNumber,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: report.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: report.statusColor.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    report.statusDisplay,
                                    style: TextStyle(
                                      color: report.statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildHeaderItem(
                                  icon: Icons.person,
                                  label: 'Author',
                                  value: report.authorName ?? 'Unknown',
                                ),
                                const SizedBox(width: 24),
                                _buildHeaderItem(
                                  icon: Icons.calendar_today,
                                  label: 'Report Date',
                                  value: DateFormat('dd MMM yyyy').format(report.reportDate),
                                ),
                                const SizedBox(width: 24),
                                _buildHeaderItem(
                                  icon: Icons.category,
                                  label: 'Type',
                                  value: report.reportType.displayName,
                                ),
                              ],
                            ),
                            if (isMobile) const SizedBox(height: 16),
                            if (isMobile && (report.canEdit || authState.isAdmin || authState.isManager))
                              Row(
                                children: [
                                  if (report.canEdit && !report.isSubmitted)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: onEdit,
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Edit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (report.canEdit && !report.isSubmitted)
                                    const SizedBox(width: 8),
                                  if (!report.isSubmitted && report.canEdit)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: onSubmitForReview,
                                        icon: const Icon(Icons.send, size: 16),
                                        label: const Text('Submit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main content in cards
                    if (isMobile)
                      Column(
                        children: [
                          _buildBasicInfoCard(context),
                          const SizedBox(height: 16),
                          _buildMetricsCard(context),
                          const SizedBox(height: 16),
                          _buildContentCard(context),
                          const SizedBox(height: 16),
                          _buildApprovalCard(context, authState, provider),
                        ],
                      )
                    else if (isTablet)
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildBasicInfoCard(context)),
                              const SizedBox(width: 16),
                              Expanded(flex: 1, child: _buildMetricsCard(context)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildContentCard(context),
                          const SizedBox(height: 16),
                          _buildApprovalCard(context, authState, provider),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildBasicInfoCard(context)),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: _buildMetricsCard(context)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildContentCard(context),
                          const SizedBox(height: 16),
                          _buildApprovalCard(context, authState, provider),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Report Type', report.reportType.displayName),
            _buildDetailRow('Period Type', report.periodType.displayName),
            _buildDetailRow('Start Date', DateFormat('dd MMM yyyy').format(report.startDate)),
            _buildDetailRow('End Date', DateFormat('dd MMM yyyy').format(report.endDate)),
            _buildDetailRow('Department', report.department),
            _buildDetailRow('Team', report.team),
            _buildDetailRow('Visibility', report.visibility.displayName),
            _buildDetailRow('Created', DateFormat('dd MMM yyyy, HH:mm').format(report.createdAt)),
            _buildDetailRow('Last Updated', DateFormat('dd MMM yyyy, HH:mm').format(report.updatedAt)),

            if (report.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: report.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                  visualDensity: VisualDensity.compact,
                ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildMetricItem(
              icon: Icons.attach_money,
              label: 'Sales Value',
              value: 'KES ${report.salesValue.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            _buildMetricItem(
              icon: Icons.leaderboard,
              label: 'Leads Generated',
              value: report.leadsGenerated.toString(),
              color: Colors.blue,
            ),
            _buildMetricItem(
              icon: Icons.trending_up,
              label: 'Opportunities',
              value: report.opportunitiesCreated.toString(),
              color: Colors.orange,
            ),
            _buildMetricItem(
              icon: Icons.check_circle,
              label: 'Deals Closed',
              value: report.dealsClosed.toString(),
              color: Colors.green,
            ),
            _buildMetricItem(
              icon: Icons.phone,
              label: 'Calls Made',
              value: report.callsMade.toString(),
              color: Colors.purple,
            ),
            _buildMetricItem(
              icon: Icons.email,
              label: 'Emails Sent',
              value: report.emailsSent.toString(),
              color: Colors.red,
            ),
            _buildMetricItem(
              icon: Icons.percent,
              label: 'Conversion Rate',
              value: '${report.conversionRate.toStringAsFixed(1)}%',
              color: Colors.teal,
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quotes Sent',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  report.quotesSent.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proposals Submitted',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  report.proposalsSubmitted.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Executive Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                report.executiveSummary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),

            if (report.achievements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Key Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...report.achievements
                  .map((achievement) => _buildAchievementItem(achievement))
                  .toList(),
            ],

            if (report.challenges.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Challenges',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...report.challenges
                  .map((challenge) => _buildChallengeItem(challenge))
                  .toList(),
            ],

            if (report.keyMetrics.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Key Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: report.keyMetrics
                    .map((metric) => _buildKeyMetricChip(metric))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, AuthState authState, ReportProvider provider) {
    final canApprove = authState.isAdmin || authState.isManager;
    final canReview = authState.isAdmin || authState.isManager || authState.user?['_id'] == report.reviewedById;

    if (!report.isSubmitted && !canApprove) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review & Approval',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            if (report.isSubmitted) ...[
              _buildApprovalItem(
                label: 'Review Status',
                value: report.reviewStatus.displayName,
                color: _getStatusColor(report.reviewStatus.name),
              ),
              _buildApprovalItem(
                label: 'Approval Status',
                value: report.approvalStatus.displayName,
                color: _getStatusColor(report.approvalStatus.name),
              ),
              if (report.reviewDate != null)
                _buildApprovalItem(
                  label: 'Reviewed On',
                  value: DateFormat('dd MMM yyyy, HH:mm').format(report.reviewDate!),
                  color: Colors.grey[600]!,
                ),
              if (report.approvalDate != null)
                _buildApprovalItem(
                  label: 'Approved On',
                  value: DateFormat('dd MMM yyyy, HH:mm').format(report.approvalDate!),
                  color: Colors.grey[600]!,
                ),
            ],

            if (report.comments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...report.comments
                  .map((comment) => _buildCommentItem(comment))
                  .toList(),
            ],

            if (canApprove && report.isSubmitted && !report.isApproved) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove ?? () => _showApproveDialog(context, provider),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(context, provider),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.description,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green[900],
            ),
          ),
          if (achievement.impact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              achievement.impact,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 13,
              ),
            ),
          ],
          if (achievement.metrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: achievement.metrics
                  .map((metric) => Chip(
                label: Text(metric),
                backgroundColor: Colors.green[100],
                labelStyle: TextStyle(
                  color: Colors.green[800],
                  fontSize: 11,
                ),
                visualDensity: VisualDensity.compact,
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengeItem(Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.description,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.orange[900],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getResolutionColor(challenge.resolutionStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  challenge.resolutionStatus.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (challenge.escalationRequired) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Escalation Required',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (challenge.solutionAttempted != null) ...[
            const SizedBox(height: 8),
            Text(
              'Solution Attempted: ${challenge.solutionAttempted}',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyMetricChip(KeyMetric metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.metricName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${metric.actual} ${metric.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTrendColor(metric.trend),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTrendIcon(metric.trend),
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${metric.trendValue}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (metric.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.notes!,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: comment.isInternal ? Colors.purple[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: comment.isInternal ? Colors.purple[100]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: comment.isInternal ? Colors.purple[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  comment.isInternal ? 'Internal' : 'External',
                  style: TextStyle(
                    color: comment.isInternal ? Colors.purple[800] : Colors.blue[800],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM, HH:mm').format(comment.commentedAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, ReportProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Report'),
        content: const Text('Are you sure you want to approve this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onApprove != null) {
                onApprove!();
              } else {
                provider.approveReport(report.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ReportProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                if (onReject != null) {
                  onReject!(controller.text.trim());
                } else {
                  provider.rejectReport(report.id, controller.text.trim());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'draft':
        return Colors.orange;
      case 'approved':
      case 'submitted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_review':
        return Colors.blue;
      case 'revisions_required':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getResolutionColor(ResolutionStatus status) {
    switch (status) {
      case ResolutionStatus.resolved:
        return Colors.green;
      case ResolutionStatus.inProgress:
        return Colors.blue;
      case ResolutionStatus.escalated:
        return Colors.red;
      case ResolutionStatus.cancelled:
        return Colors.grey;
      case ResolutionStatus.pending:
        return Colors.orange;
    }
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.blue;
      case TrendDirection.fluctuating:
        return Colors.orange;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Icons.arrow_upward;
      case TrendDirection.down:
        return Icons.arrow_downward;
      case TrendDirection.stable:
        return Icons.remove;
      case TrendDirection.fluctuating:
        return Icons.sync;
    }
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../../../core/utils/toast_utils.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/performance/performance_appraisal.model.dart';
import '../../../../providers/performance/performance_provider.dart';
import '../sub_widgets/performance/common_widgets/appraisal_card.dart';
import '../sub_widgets/performance/details/appraisal_detail_view.dart';
import '../sub_widgets/performance/forms/create_appraisal_form.dart';
import '../sub_widgets/performance/forms/review_form.dart';

class EmployeePerformanceManagementContent extends ConsumerStatefulWidget {
  const EmployeePerformanceManagementContent({super.key});

  @override
  ConsumerState<EmployeePerformanceManagementContent> createState() => _EmployeePerformanceManagementContentState();
}

class _EmployeePerformanceManagementContentState extends ConsumerState<EmployeePerformanceManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PerformanceAppraisal? _selectedAppraisal;
  bool _showCreateForm = false;
  String _filterStatus = 'all';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'all',
    'draft',
    'under_review',
    'completed',
    'acknowledged',
    'closed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load appraisals and statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(performanceProvider.notifier).fetchAppraisals();
      ref.read(performanceProvider.notifier).fetchStatistics();
      ref.read(performanceProvider.notifier).fetchEmployeeList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performanceState = ref.watch(performanceProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _selectedAppraisal == null && !_showCreateForm
          ? _buildMainContent(context, performanceState, authState)
          : _showCreateForm
          ? _buildCreateForm()
          : _buildDetailView(_selectedAppraisal!),
    );
  }

  Widget _buildMainContent(BuildContext context, PerformanceState state, AuthState authState) {
    return Column(
      children: [
        // Header with Search and Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.leaderboard,
                      size: 30,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage employee performance reviews and analytics',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (authState.hasAnyRole(['Admin', 'HR', 'Manager']))
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showCreateForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('New Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Search and Filters
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by employee name or appraisal number...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _debouncedSearch(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _filterStatus,
                    onChanged: (value) {
                      setState(() => _filterStatus = value!);
                      _applyFilters();
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('All Status'),
                          ],
                        ),
                      ),
                      ..._statusFilters.where((s) => s != 'all').map((status) {
                        final appraisalStatus = AppraisalStatus.fromString(status);
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: appraisalStatus.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(appraisalStatus.displayName),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'All Reviews'),
              Tab(text: 'Dashboard'),
              Tab(text: 'Pending Actions'),
              Tab(text: 'Reports'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllReviewsTab(state),
              _buildDashboardTab(state),
              _buildPendingActionsTab(state),
              _buildReportsTab(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllReviewsTab(PerformanceState state) {
    if (state.isLoading && state.appraisals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter appraisals
    List<PerformanceAppraisal> filteredAppraisals = state.appraisals;

    if (_filterStatus != 'all') {
      final status = AppraisalStatus.fromString(_filterStatus);
      filteredAppraisals = filteredAppraisals
          .where((a) => a.status == status)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredAppraisals = filteredAppraisals
          .where((a) =>
      a.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.appraisalNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.appraisalPeriod.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (filteredAppraisals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Performance Reviews Found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _filterStatus != 'all'
                  ? 'Try adjusting your filters or search'
                  : 'Create your first performance review',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(performanceProvider.notifier).fetchAppraisals();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAppraisals.length,
        itemBuilder: (context, index) {
          final appraisal = filteredAppraisals[index];
          return AppraisalCard(
            appraisal: appraisal,
            showActions: appraisal.canReview || appraisal.canComplete,
            onTap: () => _showAppraisalDetail(appraisal),
            onReview: appraisal.canReview ? () => _showReviewForm(appraisal) : null,
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(PerformanceState state) {
    final stats = state.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final performanceLevelStats = (stats['performanceLevelStats'] as List?)
        ?.cast<Map<String, dynamic>>() ?? [];
    final departmentStats = (stats['departmentStats'] as List?)
        ?.cast<Map<String, dynamic>>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildDashboardCard(
                title: 'Total Reviews',
                value: stats['totalAppraisals']?.toString() ?? '0',
                icon: Icons.receipt_long,
                color: Colors.blue,
                trend: '+12%',
              ),
              _buildDashboardCard(
                title: 'Completed',
                value: stats['completedAppraisals']?.toString() ?? '0',
                icon: Icons.check_circle,
                color: Colors.green,
                trend: '+8%',
              ),
              _buildDashboardCard(
                title: 'Avg. Rating',
                value: (stats['averageRating'] as num?)?.toStringAsFixed(1) ?? '0.0',
                icon: Icons.star,
                color: Colors.amber,
                trend: '+0.2',
              ),
              _buildDashboardCard(
                title: 'Pending',
                value: ((stats['totalAppraisals'] as num? ?? 0) -
                    (stats['completedAppraisals'] as num? ?? 0)).toString(),
                icon: Icons.pending_actions,
                color: Colors.orange,
                trend: '-3',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Performance Distribution Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Distribution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <BarSeries<Map<String, dynamic>, String>>[
                        BarSeries<Map<String, dynamic>, String>(
                          dataSource: performanceLevelStats,
                          xValueMapper: (data, _) => data['_id'] ?? 'Unknown',
                          yValueMapper: (data, _) => (data['count'] as num?)?.toDouble() ?? 0,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Department Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department Performance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...departmentStats.map((dept) {
                    final avgRating = (dept['averageRating'] as num?)?.toDouble() ?? 0;
                    final count = (dept['count'] as num?)?.toInt() ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dept['_id'] ?? 'Unknown Department',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '$count review${count == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildRatingBar(avgRating),
                          const SizedBox(width: 8),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getRatingColor(avgRating),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActionsTab(PerformanceState state) {
    final pendingAppraisals = state.appraisals
        .where((a) => a.status == AppraisalStatus.underReview)
        .toList();

    final draftAppraisals = state.appraisals
        .where((a) => a.status == AppraisalStatus.draft)
        .toList();

    final toAcknowledge = state.appraisals
        .where((a) => a.status == AppraisalStatus.completed && !a.employeeAcknowledged)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingAppraisals.isNotEmpty) ...[
            Text(
              'Pending Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingAppraisals.map((appraisal) => _buildActionCard(
              appraisal: appraisal,
              actionText: 'Review Now',
              actionColor: Colors.orange,
              onAction: () => _showReviewForm(appraisal),
            )).toList(),
            const SizedBox(height: 24),
          ],

          if (draftAppraisals.isNotEmpty) ...[
            Text(
              'Draft Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...draftAppraisals.map((appraisal) => _buildActionCard(
              appraisal: appraisal,
              actionText: 'Continue Editing',
              actionColor: Colors.blue,
              onAction: () => _showAppraisalDetail(appraisal),
            )).toList(),
            const SizedBox(height: 24),
          ],

          if (toAcknowledge.isNotEmpty) ...[
            Text(
              'Awaiting Employee Acknowledgment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...toAcknowledge.map((appraisal) => _buildActionCard(
              appraisal: appraisal,
              actionText: 'Remind Employee',
              actionColor: Colors.green,
              onAction: () => _sendReminder(appraisal),
            )).toList(),
          ],

          if (pendingAppraisals.isEmpty &&
              draftAppraisals.isEmpty &&
              toAcknowledge.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No pending actions at the moment',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportsTab(PerformanceState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Reports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildReportCard(
                title: 'Quarterly Performance',
                description: 'View performance trends by quarter',
                icon: Icons.timeline,
                onTap: () => _generateReport('quarterly'),
              ),
              _buildReportCard(
                title: 'Department Analysis',
                description: 'Compare department performance',
                icon: Icons.business,
                onTap: () => _generateReport('department'),
              ),
              _buildReportCard(
                title: 'Employee Ranking',
                description: 'Top performers ranking',
                icon: Icons.leaderboard,
                onTap: () => _generateReport('ranking'),
              ),
              _buildReportCard(
                title: 'Training Needs',
                description: 'Identify training requirements',
                icon: Icons.school,
                onTap: () => _generateReport('training'),
              ),
              _buildReportCard(
                title: '360° Feedback',
                description: 'Comprehensive feedback reports',
                icon: Icons.feedback,
                onTap: () => _generateReport('feedback'),
              ),
              _buildReportCard(
                title: 'Export Data',
                description: 'Export to Excel or PDF',
                icon: Icons.download,
                onTap: () => _exportData(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend.startsWith('+')
                          ? Colors.green.shade50
                          : trend.startsWith('-')
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        color: trend.startsWith('+')
                            ? Colors.green
                            : trend.startsWith('-')
                            ? Colors.red
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required PerformanceAppraisal appraisal,
    required String actionText,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appraisal.employeeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appraisal.appraisalPeriod,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appraisal.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appraisal.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: appraisal.status.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (appraisal.overallRating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRatingColor(appraisal.overallRating).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                appraisal.overallRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getRatingColor(appraisal.overallRating),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(double rating) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: rating / 5,
          child: Container(
            decoration: BoxDecoration(
              color: _getRatingColor(rating),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  void _showAppraisalDetail(PerformanceAppraisal appraisal) {
    setState(() {
      _selectedAppraisal = appraisal;
    });
  }

  Widget _buildDetailView(PerformanceAppraisal appraisal) {
    return AppraisalDetailView(
      appraisal: appraisal,
      isEmployeeView: false,
      onBack: () => setState(() => _selectedAppraisal = null),
      onReview: appraisal.canReview ? () => _showReviewForm(appraisal) : null,
      onComplete: appraisal.canComplete ? () => _showCompleteDialog(appraisal) : null,
    );
  }

  Widget _buildCreateForm() {
    return CreateAppraisalForm(
      onCancel: () => setState(() => _showCreateForm = false),
      onSuccess: (appraisal) {
        setState(() {
          _showCreateForm = false;
          _selectedAppraisal = appraisal;
        });
        ToastUtils.showSuccessToast('Performance review created successfully');
      },
    );
  }

  void _showReviewForm(PerformanceAppraisal appraisal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewForm(
        appraisal: appraisal,
        onSubmitted: () {
          Navigator.pop(context);
          ref.read(performanceProvider.notifier).fetchAppraisals();
          ToastUtils.showSuccessToast('Review submitted successfully');
        },
      ),
    );
  }

  void _showCompleteDialog(PerformanceAppraisal appraisal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Performance Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to complete this review?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Final Comments',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your final feedback...',
                ),
                onChanged: (value) {
                  // Store value for submission
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(performanceProvider.notifier).completeAppraisal(
                  appraisal.id,
                  'Review completed', // Replace with actual comment
                );
                ToastUtils.showSuccessToast('Review completed successfully');
              } catch (e) {
                ToastUtils.showErrorToast('Failed to complete review');
              }
            },
            child: const Text('Complete Review'),
          ),
        ],
      ),
    );
  }

  void _sendReminder(PerformanceAppraisal appraisal) {
    // Implementation for sending reminder
    ToastUtils.showInfoToast('Reminder sent to ${appraisal.employeeName}');
  }

  void _generateReport(String type) {
    // Implementation for generating reports
    ToastUtils.showInfoToast('$type report generated');
  }

  void _exportData() {
    // Implementation for exporting data
    ToastUtils.showInfoToast('Data exported successfully');
  }

  void _applyFilters() {
    ref.read(performanceProvider.notifier).fetchAppraisals(
      status: _filterStatus != 'all' ? _filterStatus : null,
    );
  }

  Timer? _searchTimer;
  void _debouncedSearch(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(performanceProvider.notifier).fetchAppraisals(
        search: query.isNotEmpty ? query : null,
      );
    });
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }
}
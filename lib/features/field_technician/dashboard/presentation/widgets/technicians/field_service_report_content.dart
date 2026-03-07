import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../models/field_service_report_model.dart';
import '../../../providers/field_service_report_provider.dart';
import '../sub_widgets/field_service_report/report_detail_widget.dart';
import '../sub_widgets/field_service_report/report_form_widget.dart';
import '../sub_widgets/field_service_report/report_list_view.dart';

class FieldServiceReportContent extends ConsumerStatefulWidget {
  const FieldServiceReportContent({super.key});

  @override
  ConsumerState<FieldServiceReportContent> createState() =>
      _FieldServiceReportContentState();
}

class _FieldServiceReportContentState
    extends ConsumerState<FieldServiceReportContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _filterFormKey = GlobalKey<FormState>();

  String _selectedView =
      'all'; // 'all', 'my', 'pending', 'approved', 'rejected'
  bool _showFilters = false;
  Map<String, dynamic> _filters = {};
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldServiceReportProvider.notifier).getFieldServiceReports();
      ref.read(fieldServiceReportProvider.notifier).getReportMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    ref.read(fieldServiceReportProvider.notifier).refreshReports();
    ref.read(fieldServiceReportProvider.notifier).getReportMetrics();
  }

  void _applyFilters() {
    final filters = Map<String, dynamic>.from(_filters);

    if (_dateRange != null) {
      filters['startDate'] = _dateRange!.start.toIso8601String();
      filters['endDate'] = _dateRange!.end.toIso8601String();
    }

    ref.read(fieldServiceReportProvider.notifier).updateFilters(filters);
    setState(() {
      _showFilters = false;
    });
  }

  void _clearFilters() {
    _filters.clear();
    _dateRange = null;
    _searchController.clear();
    ref.read(fieldServiceReportProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final reportState = ref.watch(fieldServiceReportProvider);
    final reports = reportState.reports;
    final metrics = reportState.reportMetrics;

    // Filter reports based on selected view
    List<FieldServiceReport> filteredReports = reports;

    switch (_selectedView) {
      case 'my':
        if (authState.user != null) {
          filteredReports = reports
              .where((r) =>
          r.technicianId == authState.user!['_id'] ||
              r.createdById == authState.user!['_id'])
              .toList();
        }
        break;
      case 'pending':
        filteredReports = reports.where((r) => r.isPending).toList();
        break;
      case 'approved':
        filteredReports = reports.where((r) => r.isApproved).toList();
        break;
      case 'rejected':
        filteredReports = reports.where((r) => r.isRejected).toList();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          _buildHeader(context, authState, reportState),

          // Metrics Section
          if (metrics != null) _buildMetricsSection(metrics),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters Panel
                if (_showFilters) _buildFiltersPanel(),

                // Reports List
                Expanded(
                  child: Column(
                    children: [
                      // View Tabs
                      _buildViewTabs(),

                      // Reports List
                      Expanded(
                        child: reportState.isLoading && reports.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : filteredReports.isEmpty
                            ? _buildEmptyState(authState)
                            : ReportListView(
                          reports: filteredReports,
                          authState: authState,
                          scrollController: _scrollController,
                          onLoadMore: () => ref
                              .read(fieldServiceReportProvider.notifier)
                              .loadMoreReports(),
                          isLoadingMore: reportState.isLoading,
                          hasMore: reportState.hasMore,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: authState.hasRole('Technician')
          ? FloatingActionButton.extended(
        onPressed: () => _showCreateReportDialog(context, authState),
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
        backgroundColor: Colors.blue,
      )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState,
      FieldServiceReportState reportState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Field Service Reports',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Search Bar
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(fieldServiceReportProvider.notifier)
                            .getFieldServiceReports();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(fieldServiceReportProvider.notifier)
                        .setSearchQuery(value);
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Filter Button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  color: _showFilters ? Colors.blue : Colors.grey,
                ),
                label: const Text('Filters'),
              ),

              const SizedBox(width: 12),

              // Refresh Button
              IconButton(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),

              // Export Button (for managers/admins)
              if (authState.hasAnyRole(['Manager', 'Admin']))
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: ListTile(
                        leading: Icon(Icons.download),
                        title: Text('Export Reports'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'metrics',
                      child: ListTile(
                        leading: Icon(Icons.analytics),
                        title: Text('Detailed Analytics'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'export') {
                      _exportReports();
                    } else if (value == 'metrics') {
                      _showDetailedMetrics();
                    }
                  },
                ),
            ],
          ),

          // Quick Stats
          const SizedBox(height: 16),
          _buildQuickStats(reportState),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FieldServiceReportState reportState) {
    final stats = ref.read(reportStatsProvider);

    return Row(
      children: [
        _buildStatCard(
          'Total Reports',
          '${stats['total']}',
          Icons.assignment,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Pending',
          '${stats['pending']}',
          Icons.pending_actions,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Approved',
          '${stats['approved']}',
          Icons.check_circle,
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Avg. Satisfaction',
          '${(stats['averageSatisfaction'] as double? ?? 0.0).toStringAsFixed(1)}/5',
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSection(Map<String, dynamic> metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.only(top: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<Map<String, dynamic>, String>(
                        dataSource:
                        (metrics['approvalStatusCounts'] as List<dynamic>?)
                            ?.cast<Map<String, dynamic>>() ??
                            [],
                        xValueMapper: (data, _) => data['_id'],
                        yValueMapper: (data, _) =>
                        data['count']?.toDouble() ?? 0,
                        color: Colors.blue,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<Map<String, dynamic>, String>(
                        dataSource:
                        (metrics['technicianPerformance'] as List<dynamic>?)
                            ?.cast<Map<String, dynamic>>() ??
                            [],
                        xValueMapper: (data, _) => data['technicianName'],
                        yValueMapper: (data, _) =>
                        data['reportCount']?.toDouble() ?? 0,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showFilters = false;
                  });
                },
              ),
            ],
          ),
          Form(
            key: _filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Approval Status',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                ...ApprovalStatus.values.map((status) {
                  return CheckboxListTile(
                    title: Text(status.displayName),
                    value: _filters['approvalStatus'] == status.apiValue,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _filters['approvalStatus'] = status.apiValue;
                        } else {
                          _filters.remove('approvalStatus');
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }),
                const SizedBox(height: 16),
                const Text('Date Range',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                OutlinedButton(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (range != null) {
                      setState(() {
                        _dateRange = range;
                      });
                    }
                  },
                  child: Text(
                    _dateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildViewTab('All', 'all'),
          const SizedBox(width: 8),
          _buildViewTab('My Reports', 'my'),
          const SizedBox(width: 8),
          _buildViewTab('Pending', 'pending'),
          const SizedBox(width: 8),
          _buildViewTab('Approved', 'approved'),
          const SizedBox(width: 8),
          _buildViewTab('Rejected', 'rejected'),
        ],
      ),
    );
  }

  Widget _buildViewTab(String label, String value) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AuthState authState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedView == 'my'
                ? 'No reports created by you yet'
                : 'No field service reports found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedView == 'my'
                ? 'Create your first field service report'
                : 'Try adjusting your filters or create a new report',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (authState.hasRole('Technician'))
            ElevatedButton.icon(
              onPressed: () => _showCreateReportDialog(context, authState),
              icon: const Icon(Icons.add),
              label: const Text('Create Report'),
            ),
        ],
      ),
    );
  }

  void _showCreateReportDialog(BuildContext context, AuthState authState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: ReportFormWidget(
            authState: authState,
            onSuccess: (report) {
              Navigator.pop(context);
              _showReportDetails(report);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _showReportDetails(FieldServiceReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReportDetailWidget(
        report: report,
        authState: ref.read(authProvider),
        onReportUpdated: () {
          ref.read(fieldServiceReportProvider.notifier).refreshReports();
        },
      ),
    );
  }

  void _exportReports() {
    // Implement export functionality
    print('Export reports');
  }

  void _showDetailedMetrics() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: _buildDetailedMetricsView(),
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsView() {
    final metrics = ref.read(fieldServiceReportProvider).reportMetrics;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (metrics != null)
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Add detailed metrics visualization here
                    Text('Metrics data available'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../models/field_service_report_model.dart';
import '../../../providers/field_service_report_provider.dart';
import '../sub_widgets/field_service_report/bulk_actions_bar.dart';
import '../sub_widgets/field_service_report/empty_state.dart';
import '../sub_widgets/field_service_report/management_filters_panel.dart';
import '../sub_widgets/field_service_report/management_header.dart';
import '../sub_widgets/field_service_report/management_metrics_section.dart';
import '../sub_widgets/field_service_report/management_reports_grid.dart';
import '../sub_widgets/field_service_report/management_reports_list.dart';
import '../sub_widgets/field_service_report/report_detail_widget.dart';
import '../sub_widgets/field_service_report/view_tabs.dart';

class FieldServiceReportManagementContent extends ConsumerStatefulWidget {
  const FieldServiceReportManagementContent({super.key});

  @override
  ConsumerState<FieldServiceReportManagementContent> createState() =>
      _FieldServiceReportManagementContentState();
}

class _FieldServiceReportManagementContentState
    extends ConsumerState<FieldServiceReportManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedView = 'all'; // 'all', 'pending', 'approved', 'rejected', 'recent'
  bool _showFilters = false;
  bool _showBulkActions = false;
  Map<String, dynamic> _filters = {};
  DateTimeRange? _dateRange;
  List<String> _selectedReportIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
    setState(() {
      _selectedReportIds.clear();
      _showBulkActions = false;
    });
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
    _selectedReportIds.clear();
    _showBulkActions = false;
    ref.read(fieldServiceReportProvider.notifier).clearFilters();
  }

  void _toggleReportSelection(String reportId) {
    setState(() {
      if (_selectedReportIds.contains(reportId)) {
        _selectedReportIds.remove(reportId);
      } else {
        _selectedReportIds.add(reportId);
      }
      _showBulkActions = _selectedReportIds.isNotEmpty;
    });
  }

  List<FieldServiceReport> _getSelectedReports(List<FieldServiceReport> allReports) {
    return allReports.where((r) => _selectedReportIds.contains(r.id)).toList();
  }

  List<FieldServiceReport> _filterReports(List<FieldServiceReport> reports) {
    switch (_selectedView) {
      case 'pending':
        return reports.where((r) => r.isPending).toList();
      case 'approved':
        return reports.where((r) => r.isApproved).toList();
      case 'rejected':
        return reports.where((r) => r.isRejected).toList();
      case 'recent':
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        return reports.where((r) => r.createdAt.isAfter(cutoff)).toList();
      default:
        return reports;
    }
  }

  Future<void> _handleReportAction(String action, FieldServiceReport report) async {
    final provider = ref.read(fieldServiceReportProvider.notifier);

    switch (action) {
      case 'view':
        _showReportDetails(report);
        break;
      case 'approve':
        final qualityCheck = await _showQualityCheckDialog();
        if (qualityCheck != null) {
          await provider.approveReport(report.id, qualityCheck: qualityCheck);
          _refreshData();
        }
        break;
      case 'reject':
        final comments = await _showRejectDialog();
        if (comments != null) {
          await provider.rejectReport(report.id, comments: comments);
          _refreshData();
        }
        break;
      case 'pdf':
      // Generate PDF
        break;
    }
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
          _refreshData();
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _showQualityCheckDialog() async {
    // Implement quality check dialog
    return null;
  }

  Future<String?> _showRejectDialog() async {
    // Implement reject dialog
    return null;
  }

  Future<void> _bulkApproveReports(List<FieldServiceReport> reports) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Approve Reports'),
        content: Text('Are you sure you want to approve ${reports.length} reports?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = ref.read(fieldServiceReportProvider.notifier);
      for (final report in reports.where((r) => r.canApprove)) {
        await provider.approveReport(report.id);
      }
      _refreshData();
    }
  }

  Future<void> _bulkRejectReports(List<FieldServiceReport> reports) async {
    final comments = await _showRejectDialog();
    if (comments != null && comments.isNotEmpty) {
      final provider = ref.read(fieldServiceReportProvider.notifier);
      for (final report in reports.where((r) => r.canApprove)) {
        await provider.rejectReport(report.id, comments: comments);
      }
      _refreshData();
    }
  }

  void _exportSelectedReports() {
    if (_selectedReportIds.isEmpty) return;
    print('Exporting ${_selectedReportIds.length} reports');
  }

  void _exportAllReports() {
    final reports = ref.read(fieldServiceReportProvider).reports;
    print('Exporting all ${reports.length} reports');
  }

  void _showAdvancedAnalytics() {
    // Implement advanced analytics dialog
  }

  void _onExportAction(String value) {
    if (value == 'export') {
      _exportSelectedReports();
    } else if (value == 'export_all') {
      _exportAllReports();
    } else if (value == 'analytics') {
      _showAdvancedAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final reportState = ref.watch(fieldServiceReportProvider);
    final allReports = reportState.reports;
    final metrics = reportState.reportMetrics;

    final filteredReports = _filterReports(allReports);
    final selectedReports = _getSelectedReports(filteredReports);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          ManagementHeader(
            searchController: _searchController,
            showFilters: _showFilters,
            onToggleFilters: () => setState(() => _showFilters = !_showFilters),
            onRefresh: _refreshData,
            filteredCount: filteredReports.length,
            selectedCount: _selectedReportIds.length,
            onExportAction: _onExportAction,
          ),

          // Bulk Actions Bar
          if (_showBulkActions)
            BulkActionsBar(
              selectedCount: _selectedReportIds.length,
              selectedReports: selectedReports,
              onBulkApprove: () => _bulkApproveReports(selectedReports),
              onBulkReject: () => _bulkRejectReports(selectedReports),
              onExportSelected: _exportSelectedReports,
              onClearSelection: () => setState(() {
                _selectedReportIds.clear();
                _showBulkActions = false;
              }),
            ),

          // Metrics Section
          if (metrics != null)
            ManagementMetricsSection(metrics: metrics),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters Panel
                if (_showFilters)
                  ManagementFiltersPanel(
                    filters: _filters,
                    dateRange: _dateRange,
                    onFiltersUpdated: (newFilters) =>
                        setState(() => _filters = newFilters),
                    onDateRangeUpdated: (range) =>
                        setState(() => _dateRange = range),
                    onApplyFilters: _applyFilters,
                    onClearFilters: _clearFilters,
                    onClose: () => setState(() => _showFilters = false),
                  ),

                // Reports Content
                Expanded(
                  child: Column(
                    children: [
                      // View Tabs
                      ManagementViewTabs(
                        selectedView: _selectedView,
                        onViewChanged: (view) => setState(() {
                          _selectedView = view;
                          _selectedReportIds.clear();
                          _showBulkActions = false;
                        }),
                        tabControllerIndex: _tabController.index,
                        onTabChanged: (index) => _tabController.animateTo(index),
                      ),

                      // Reports Grid/List
                      Expanded(
                        child: reportState.isLoading && allReports.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : filteredReports.isEmpty
                            ? ManagementEmptyState(
                          selectedView: _selectedView,
                        )
                            : IndexedStack(
                          index: _tabController.index,
                          children: [
                            // Grid View
                            ManagementReportsGrid(
                              reports: filteredReports,
                              selectedReportIds: _selectedReportIds,
                              onToggleSelection: _toggleReportSelection,
                              onViewDetails: _showReportDetails,
                              onReportAction: _handleReportAction,
                            ),

                            // List View
                            ManagementReportsList(
                              reports: filteredReports,
                              authState: authState,
                              selectedReportIds: _selectedReportIds,
                              onToggleSelection: _toggleReportSelection,
                              onViewDetails: _showReportDetails,
                              onReportAction: _handleReportAction,
                            ),
                          ],
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
    );
  }
}
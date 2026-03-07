import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/reports/management_report_model.dart';
import '../../providers/management_report_provider.dart';
import 'sub_widgets/reports/report_detail_sheet.dart';
import 'sub_widgets/reports/report_filter_sheet.dart';
import 'sub_widgets/reports/report_form_dialog.dart';
import 'sub_widgets/reports/report_list_card.dart';

class ManagementReportsContent extends ConsumerStatefulWidget {
  const ManagementReportsContent({super.key});

  @override
  ConsumerState<ManagementReportsContent> createState() =>
      _ManagementReportsContentState();
}

class _ManagementReportsContentState
    extends ConsumerState<ManagementReportsContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(managementReportProvider.notifier).loadReports();
    await ref.read(managementReportProvider.notifier).loadReportStats();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        ref.read(managementReportProvider).currentPage <
            ref.read(managementReportProvider).totalPages) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    final currentPage = ref.read(managementReportProvider).currentPage;
    await ref
        .read(managementReportProvider.notifier)
        .loadReports(additionalFilters: {'page': currentPage + 1});
    setState(() => _isLoadingMore = false);
  }

  void _showReportDetails(ManagementReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailSheet(
        report: report,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const ReportFormDialog(),
    );
  }

  void _showEditDialog(ManagementReport report) {
    showDialog(
      context: context,
      builder: (context) => ReportFormDialog(report: report),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReportFilterSheet(),
    );
  }

  void _confirmDelete(ManagementReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(managementReportProvider.notifier)
                  .deleteReport(report.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managementReportProvider);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                const Text(
                  'Management Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create, manage, and track all management reports',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                // Stats
                if (stats != null)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatCard(
                          'Total Reports',
                          stats['totalReports'].toString(),
                          Icons.description,
                          Colors.blue,
                        ),
                        ..._buildStatusStats(stats['byStatus'] ?? {}),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Action Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (value) {
                          ref
                              .read(managementReportProvider.notifier)
                              .updateFilters({'search': value});
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterSheet,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Reports List
          Expanded(
            child: state.isLoading && state.reports.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.reports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No reports found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first management report',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 16, bottom: 80),
                          itemCount:
                              state.reports.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.reports.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final report = state.reports[index];
                            return ReportListCard(
                              report: report,
                              onTap: () => _showReportDetails(report),
                              onEdit: report.isEditable
                                  ? () => _showEditDialog(report)
                                  : null,
                              onDelete: () => _confirmDelete(report),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusStats(Map<String, dynamic> statusStats) {
    final widgets = <Widget>[];
    statusStats.forEach((status, count) {
      final reportStatus = ReportStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ReportStatus.draft,
      );
      widgets.add(
        _buildStatCard(
          reportStatus.displayName,
          count.toString(),
          reportStatus.icon,
          reportStatus.color,
        ),
      );
    });
    return widgets;
  }
}

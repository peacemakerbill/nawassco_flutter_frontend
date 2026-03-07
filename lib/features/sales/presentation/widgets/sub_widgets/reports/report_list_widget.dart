import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/report.model.dart';
import '../../../../providers/report_provider.dart';
import 'responsive.dart';
import 'report_card_widget.dart';
import 'report_filters_widget.dart';

class ReportListWidget extends ConsumerWidget {
  final bool showFilters;
  final bool showCreateButton;
  final VoidCallback? onCreateReport;
  final Function(Report)? onViewReport;
  final Function(Report)? onEditReport;

  const ReportListWidget({
    super.key,
    this.showFilters = true,
    this.showCreateButton = true,
    this.onCreateReport,
    this.onViewReport,
    this.onEditReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportProvider);
    final provider = ref.read(reportProvider.notifier);

    if (state.isLoading && state.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showFilters)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReportFiltersWidget(
              filters: state.filters,
              onFiltersChanged: (filters) => provider.updateFilters(filters),
              onClearFilters: () => provider.clearFilters(),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports (${state.totalItems})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showCreateButton && onCreateReport != null)
                ElevatedButton.icon(
                  onPressed: onCreateReport,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),

        if (state.reports.isEmpty && !state.isLoading)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No reports found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    state.filters.hasFilters ? 'Try adjusting your filters' : 'Create your first report',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  if (!state.filters.hasFilters && showCreateButton)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(onPressed: onCreateReport, child: const Text('Create Report')),
                    ),
                ],
              ),
            ),
          ),

        if (state.reports.isNotEmpty)
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !state.isLoading) {
                  provider.loadNextPage();
                }
                return false;
              },
              child: Responsive.isMobile(context)
                  ? ListView.builder(
                itemCount: state.reports.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.reports.length) {
                    return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                  }
                  final report = state.reports[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportCardWidget(
                      report: report,
                      onTap: () => _handleReportTap(report, context, provider),
                    ),
                  );
                },
              )
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isTablet(context) ? 2 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: Responsive.isTablet(context) ? 1.5 : 1.8,
                ),
                itemCount: state.reports.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.reports.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final report = state.reports[index];
                  return ReportCardWidget(
                    report: report,
                    onTap: () => _handleReportTap(report, context, provider),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _handleReportTap(Report report, BuildContext context, ReportProvider provider) {
    provider.selectReport(report);
    if (onViewReport != null) {
      onViewReport!(report);
    } else {
      provider.setViewMode(ViewMode.details);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../providers/field_service_report_provider.dart';

class ManagementHeader extends ConsumerWidget {
  final TextEditingController searchController;
  final bool showFilters;
  final Function() onToggleFilters;
  final Function() onRefresh;
  final int filteredCount;
  final int selectedCount;
  final Function(String) onExportAction;

  const ManagementHeader({
    super.key,
    required this.searchController,
    required this.showFilters,
    required this.onToggleFilters,
    required this.onRefresh,
    required this.filteredCount,
    required this.selectedCount,
    required this.onExportAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final reportState = ref.watch(fieldServiceReportProvider);

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
              const Icon(Icons.supervisor_account, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Report Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Search Bar
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
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
                onPressed: onToggleFilters,
                icon: Icon(
                  showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  color: showFilters ? Colors.blue : Colors.grey,
                ),
                label: const Text('Filters'),
              ),

              const SizedBox(width: 12),

              // Refresh Button
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),

              // Export Button
              ExportMenuButton(
                onExportAction: onExportAction,
              ),
            ],
          ),

          // Quick Stats
          const SizedBox(height: 16),
          ManagementQuickStats(
            reportState: reportState,
            filteredCount: filteredCount,
            selectedCount: selectedCount,
          ),
        ],
      ),
    );
  }
}

class ExportMenuButton extends StatelessWidget {
  final Function(String) onExportAction;

  const ExportMenuButton({super.key, required this.onExportAction});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'export',
          child: ListTile(
            leading: Icon(Icons.download),
            title: Text('Export Selected'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'export_all',
          child: ListTile(
            leading: Icon(Icons.download_for_offline),
            title: Text('Export All Filtered'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'analytics',
          child: ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Advanced Analytics'),
          ),
        ),
      ],
      onSelected: onExportAction,
    );
  }
}

class ManagementQuickStats extends ConsumerWidget {
  final FieldServiceReportState reportState;
  final int filteredCount;
  final int selectedCount;

  const ManagementQuickStats({
    super.key,
    required this.reportState,
    required this.filteredCount,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.read(reportStatsProvider);

    return Row(
      children: [
        _buildStatCard('Total Reports', '${stats['total']}', Icons.assignment, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Pending Approval', '${stats['pending']}', Icons.pending_actions, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard('Approved', '${stats['approved']}', Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Filtered', '$filteredCount', Icons.filter_list, Colors.purple),
        const SizedBox(width: 12),
        _buildStatCard('Selected', '$selectedCount', Icons.check_box, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
}
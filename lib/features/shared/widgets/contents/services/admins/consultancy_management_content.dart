import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/consultancy_model.dart';
import '../../../../providers/consultancy_provider.dart';
import '../../../dialogs/consultancy/confirm_dialog.dart';
import '../../../sub_widgets/consultancy/consultancy_application_form.dart';
import '../../../sub_widgets/consultancy/consultancy_card.dart';
import '../../../sub_widgets/consultancy/consultancy_detail_view.dart';
import '../../../sub_widgets/consultancy/consultancy_stats_chart.dart';

class ConsultancyManagementContent extends ConsumerStatefulWidget {
  const ConsultancyManagementContent({super.key});

  @override
  ConsumerState<ConsultancyManagementContent> createState() => _ConsultancyManagementContentState();
}

class _ConsultancyManagementContentState extends ConsumerState<ConsultancyManagementContent> {
  final _searchController = TextEditingController();
  ConsultancyStatus? _selectedFilter;
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consultancyProvider.notifier).fetchConsultancies();
      ref.read(consultancyProvider.notifier).fetchConsultancyStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    ref.read(consultancyProvider.notifier).setSearchQuery(query);
  }

  void _applyFilter(ConsultancyStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
    ref.read(consultancyProvider.notifier).setFilterStatus(status);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedFilter = null;
    });
    ref.read(consultancyProvider.notifier).clearFilters();
  }

  Future<void> _deleteConsultancy(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'Delete Consultancy',
        message: 'Are you sure you want to delete this consultancy? This action cannot be undone.',
      ),
    );

    if (confirmed == true) {
      await ref.read(consultancyProvider.notifier).deleteConsultancy(id);
    }
  }

  void _editConsultancy(Consultancy consultancy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ConsultancyApplicationForm(
          initialData: consultancy,
          onSuccess: () {
            Navigator.pop(context);
            ref.read(consultancyProvider.notifier).fetchConsultancies();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final consultancyState = ref.watch(consultancyProvider);
    final consultancies = consultancyState.filteredConsultancies;
    final selectedConsultancy = consultancyState.selectedConsultancy;
    final stats = consultancyState.stats;

    // Check if user has management permissions
    final canManage = authState.hasAnyRole(['Admin', 'Manager', 'HR']);
    if (!canManage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to access consultancy management.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (selectedConsultancy != null) {
      return ConsultancyDetailView(consultancy: selectedConsultancy);
    }

    return Scaffold(
      body: Column(
        children: [
          // Management Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.manage_accounts,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultancy Management',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage all consultancy applications and projects',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showStats = !_showStats),
                      icon: Icon(
                        _showStats ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      tooltip: _showStats ? 'Hide Stats' : 'Show Stats',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick stats
                if (_showStats && stats != null) ...[
                  _buildQuickStats(stats),
                  const SizedBox(height: 16),
                ],

                // Search and filter bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by title, number, or client...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: _applySearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<ConsultancyStatus>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, color: Colors.white),
                            if (_selectedFilter != null) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...ConsultancyStatus.values.map((status) {
                          return PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  status.statusIcon,
                                  color: status.statusColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onSelected: _applyFilter,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Clear filters',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats chart
          if (_showStats && stats != null)
            ConsultancyStatsChart(stats: stats),

          // Management actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Consultancy Projects',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${consultancies.length} projects',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Consultancies list
          Expanded(
            child: consultancies.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    consultancyState.isLoading
                        ? 'Loading consultancies...'
                        : 'No consultancies found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                await ref.read(consultancyProvider.notifier).fetchConsultancies();
                await ref.read(consultancyProvider.notifier).fetchConsultancyStats();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: consultancies.length,
                itemBuilder: (context, index) {
                  final consultancy = consultancies[index];
                  return ConsultancyCard(
                    consultancy: consultancy,
                    onTap: () {
                      ref.read(consultancyProvider.notifier)
                          .selectConsultancy(consultancy);
                    },
                    onEdit: () => _editConsultancy(consultancy),
                    onDelete: () => _deleteConsultancy(consultancy.id),
                    showActions: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for creating new consultancy
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ConsultancyApplicationForm(
                onSuccess: () {
                  Navigator.pop(context);
                  ref.read(consultancyProvider.notifier).fetchConsultancies();
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Consultancy'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    final totalConsultancies = stats['totalConsultancies'] ?? 0;
    final totalBudget = stats['totalBudget'] ?? 0.0;
    final statusCounts = (stats['statusCounts'] as List?) ?? [];

    return Row(
      children: [
        _buildStatItem(
          icon: Icons.business_center,
          value: totalConsultancies.toString(),
          label: 'Total Projects',
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.attach_money,
          value: 'KES ${NumberFormat('#,##0').format(totalBudget)}',
          label: 'Total Budget',
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.trending_up,
          value: statusCounts
              .where((s) => s['status'] == 'ACTIVE' || s['status'] == 'APPROVED')
              .fold(0, (sum, s) => sum + ((s['count'] as int) ?? 0))
              .toString(),
          label: 'Active',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
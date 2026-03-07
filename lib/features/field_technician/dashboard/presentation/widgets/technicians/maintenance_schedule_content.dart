import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/maintenance_schedule.dart';
import '../../../providers/maintenance_schedule_provider.dart';

import '../sub_widgets/maintenance_schedule/maintenance_schedule_card.dart';
import '../sub_widgets/maintenance_schedule/maintenance_schedule_details.dart';
import '../sub_widgets/maintenance_schedule/maintenance_schedule_form.dart';
import '../sub_widgets/maintenance_schedule/metrics_dashboard.dart';

class MaintenanceScheduleContent extends ConsumerStatefulWidget {
  const MaintenanceScheduleContent({super.key});

  @override
  ConsumerState<MaintenanceScheduleContent> createState() => _MaintenanceScheduleContentState();
}

class _MaintenanceScheduleContentState extends ConsumerState<MaintenanceScheduleContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(maintenanceScheduleProvider.notifier).loadMaintenanceSchedules();
      ref.read(maintenanceScheduleProvider.notifier).loadMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceScheduleProvider);
    final notifier = ref.read(maintenanceScheduleProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          _buildHeader(state, notifier),

          // Metrics Dashboard - Only show on dashboard tab
          if (_tabController.index == 0)
            MetricsDashboard(metrics: state.metrics),

          // Content Area
          Expanded(
            child: Column(
              children: [
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'All Schedules'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Overdue'),
                    ],
                    onTap: (index) {
                      if (index == 2) {
                        notifier.setStatusFilter(MaintenanceStatus.scheduled);
                        notifier.setShowOverdue(false);
                      } else if (index == 3) {
                        notifier.setStatusFilter(null);
                        notifier.setShowOverdue(true);
                      } else {
                        notifier.clearFilters();
                      }
                    },
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(state, notifier),
                      _buildAllSchedulesTab(state, notifier),
                      _buildUpcomingTab(state, notifier),
                      _buildOverdueTab(state, notifier),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateForm(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildHeader(MaintenanceScheduleState state, MaintenanceScheduleProvider notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Maintenance Schedules',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              // Quick Stats
              Row(
                children: [
                  _buildQuickStat('Total', state.schedules.length.toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _buildQuickStat('Overdue', state.overdueSchedules.length.toString(), Colors.red),
                  const SizedBox(width: 16),
                  _buildQuickStat('In Progress', state.inProgressSchedules.length.toString(), Colors.orange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search and Filters Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search schedules...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: notifier.searchMaintenanceSchedules,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            notifier.searchMaintenanceSchedules('');
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                onSelected: (value) => _handleFilterSelection(value, notifier),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'clear', child: Text('Clear All Filters')),
                  const PopupMenuDivider(),
                  ...MaintenanceTargetType.values.map((type) =>
                      PopupMenuItem(value: 'target_${type.name}', child: Text('Target: ${type.displayName}'))
                  ).toList(),
                  const PopupMenuDivider(),
                  ...MaintenanceStatus.values.map((status) =>
                      PopupMenuItem(value: 'status_${status.name}', child: Text('Status: ${status.displayName}'))
                  ).toList(),
                  const PopupMenuDivider(),
                  ...PriorityLevel.values.map((priority) =>
                      PopupMenuItem(value: 'priority_${priority.name}', child: Text('Priority: ${priority.displayName}'))
                  ).toList(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab(MaintenanceScheduleState state, MaintenanceScheduleProvider notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Create Schedule',
                  Icons.add_circle,
                  Colors.blue,
                      () => _showCreateForm(context, notifier),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'View Overdue',
                  Icons.warning,
                  Colors.red,
                      () => _tabController.animateTo(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Upcoming',
                  Icons.schedule,
                  Colors.orange,
                      () => _tabController.animateTo(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cost Analysis Section
          _buildCostAnalysisSection(state.metrics),
          const SizedBox(height: 16),

          // Recent Schedules
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Maintenance Schedules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...state.schedules.take(5).map((schedule) =>
                      MaintenanceScheduleCard(
                        schedule: schedule,
                        onTap: () => _showDetails(context, schedule, notifier),
                      )
                  ).toList(),
                  if (state.schedules.length > 5) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => _tabController.animateTo(1),
                        child: const Text('View All Schedules'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSchedulesTab(MaintenanceScheduleState state, MaintenanceScheduleProvider notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Maintenance Schedules Found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Create your first maintenance schedule',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateForm(context, notifier),
              child: const Text('Create Schedule'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadMaintenanceSchedules(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredSchedules.length,
        itemBuilder: (context, index) {
          final schedule = state.filteredSchedules[index];
          return MaintenanceScheduleCard(
            schedule: schedule,
            onTap: () => _showDetails(context, schedule, notifier),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTab(MaintenanceScheduleState state, MaintenanceScheduleProvider notifier) {
    final upcoming = state.upcomingSchedules;

    if (upcoming.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Upcoming Maintenance',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadMaintenanceSchedules(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          final schedule = upcoming[index];
          return MaintenanceScheduleCard(
            schedule: schedule,
            onTap: () => _showDetails(context, schedule, notifier),
          );
        },
      ),
    );
  }

  Widget _buildOverdueTab(MaintenanceScheduleState state, MaintenanceScheduleProvider notifier) {
    final overdue = state.overdueSchedules;

    if (overdue.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No Overdue Maintenance',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              'Great job! All maintenance is up to date.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadMaintenanceSchedules(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: overdue.length,
        itemBuilder: (context, index) {
          final schedule = overdue[index];
          return MaintenanceScheduleCard(
            schedule: schedule,
            onTap: () => _showDetails(context, schedule, notifier),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostAnalysisSection(Map<String, dynamic> metrics) {
    final costAnalysis = _getCostAnalysisData(metrics);

    if (costAnalysis.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Cost Analysis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.attach_money, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'No cost data available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final totalEstimated = costAnalysis['totalEstimatedCost'] ?? 0.0;
    final totalActual = costAnalysis['totalActualCost'] ?? 0.0;
    final averageVariance = costAnalysis['averageVariance'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCostMetricRow('Total Estimated Cost', totalEstimated, Colors.blue),
            _buildCostMetricRow('Total Actual Cost', totalActual, Colors.green),
            _buildCostMetricRow(
              'Average Variance',
              averageVariance,
              averageVariance >= 0 ? Colors.red : Colors.green,
              showPositivePrefix: true,
            ),
            const SizedBox(height: 16),
            _buildVarianceIndicator(averageVariance),
          ],
        ),
      ),
    );
  }

  Widget _buildCostMetricRow(String label, double value, Color color, {bool showPositivePrefix = false}) {
    final formattedValue = value >= 0
        ? '\$${value.toStringAsFixed(2)}'
        : '-\$${value.abs().toStringAsFixed(2)}';

    final displayValue = showPositivePrefix && value > 0
        ? '+$formattedValue'
        : formattedValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceIndicator(double variance) {
    final isPositive = variance >= 0;
    final percentage = variance != 0 ? (variance.abs() * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPositive
                  ? 'Costs are $percentage% over budget on average'
                  : 'Costs are $percentage% under budget on average',
              style: TextStyle(
                color: isPositive ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCostAnalysisData(Map<String, dynamic> metrics) {
    final costAnalysis = metrics['costAnalysis'] ?? [];
    if (costAnalysis.isNotEmpty && costAnalysis[0] is Map) {
      return costAnalysis[0];
    }
    return {};
  }

  void _handleFilterSelection(String value, MaintenanceScheduleProvider notifier) {
    switch (value) {
      case 'clear':
        notifier.clearFilters();
        break;
      default:
        if (value.startsWith('target_')) {
          final typeName = value.replaceFirst('target_', '');
          final type = MaintenanceTargetType.values.firstWhere((e) => e.name == typeName);
          notifier.setTargetTypeFilter(type);
        } else if (value.startsWith('status_')) {
          final statusName = value.replaceFirst('status_', '');
          final status = MaintenanceStatus.values.firstWhere((e) => e.name == statusName);
          notifier.setStatusFilter(status);
        } else if (value.startsWith('priority_')) {
          final priorityName = value.replaceFirst('priority_', '');
          final priority = PriorityLevel.values.firstWhere((e) => e.name == priorityName);
          notifier.setPriorityFilter(priority);
        }
    }
  }

  void _showCreateForm(BuildContext context, MaintenanceScheduleProvider notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaintenanceScheduleForm(
        onSubmit: (data) async {
          final success = await notifier.createMaintenanceSchedule(data);
          if (success && context.mounted) {
            Navigator.pop(context);
          }
          return success;
        },
      ),
    );
  }

  void _showDetails(BuildContext context, MaintenanceSchedule schedule, MaintenanceScheduleProvider notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaintenanceScheduleDetails(
        schedule: schedule,
        onUpdate: (updatedSchedule) {
          notifier.selectSchedule(updatedSchedule);
        },
      ),
    );
  }
}
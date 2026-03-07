import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/strategic_plan_model.dart';
import '../../providers/strategic_plan_provider.dart';
import 'sub_widgets/strategic_plan/strategic_plan_card.dart';
import 'sub_widgets/strategic_plan/strategic_plan_details.dart';
import 'sub_widgets/strategic_plan/strategic_plan_form.dart';

class StrategicPlanContent extends ConsumerStatefulWidget {
  const StrategicPlanContent({super.key});

  @override
  ConsumerState<StrategicPlanContent> createState() => _StrategicPlanContentState();
}

class _StrategicPlanContentState extends ConsumerState<StrategicPlanContent> {
  @override
  void initState() {
    super.initState();
    // Load strategic plans when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(strategicPlanProvider.notifier).loadStrategicPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(strategicPlanProvider);
    final provider = ref.read(strategicPlanProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _buildBody(state, provider),
      floatingActionButton: _buildFloatingActionButton(state, provider),
    );
  }

  Widget _buildBody(StrategicPlanState state, StrategicPlanProvider provider) {
    switch (state.viewMode) {
      case ViewMode.list:
        return _buildListView(state, provider);
      case ViewMode.details:
        return state.selectedPlan != null
            ? StrategicPlanDetails(plan: state.selectedPlan!)
            : _buildListView(state, provider);
      case ViewMode.create:
        return const StrategicPlanForm();
      case ViewMode.edit:
        return state.selectedPlan != null
            ? StrategicPlanForm(initialData: state.selectedPlan)
            : _buildListView(state, provider);
    }
  }

  Widget _buildListView(StrategicPlanState state, StrategicPlanProvider provider) {
    final plans = state.filteredPlans;
    final isLoading = state.isLoading;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          floating: true,
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Strategic Plans'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade600,
                  ],
                ),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Icon(
                      Icons.track_changes,
                      size: 80,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Filters and Search
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildFilters(provider, state),
          ),
        ),

        // Stats Overview
        if (!isLoading && plans.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _buildStatsOverview(plans),
            ),
          ),

        // Loading State
        if (isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),

        // Empty State
        if (!isLoading && plans.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(provider),
          ),

        // Plans List
        if (!isLoading && plans.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StrategicPlanCard(plan: plans[index]),
                  );
                },
                childCount: plans.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(StrategicPlanProvider provider, StrategicPlanState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Search strategic plans...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery?.isNotEmpty == true
                    ? IconButton(
                  onPressed: () => provider.setSearchQuery(''),
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: provider.setSearchQuery,
              initialValue: state.searchQuery,
            ),

            const SizedBox(height: 16),

            // Filter Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Status Filters
                ...PlanStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.label),
                    selected: state.filterStatus == status,
                    onSelected: (selected) {
                      provider.setFilterStatus(selected ? status : null);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: _getStatusColor(status).withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: state.filterStatus == status
                          ? _getStatusColor(status)
                          : Colors.grey.shade700,
                    ),
                  );
                }).toList(),

                // Fiscal Year Filter
                if (_getAvailableFiscalYears().isNotEmpty)
                  ..._getAvailableFiscalYears().map((year) {
                    return FilterChip(
                      label: Text(year),
                      selected: state.filterFiscalYear == year,
                      onSelected: (selected) {
                        provider.setFilterFiscalYear(selected ? year : null);
                      },
                    );
                  }).toList(),

                // Clear Filters
                if (state.filterStatus != null || state.filterFiscalYear != null)
                  ActionChip(
                    label: const Text('Clear Filters'),
                    onPressed: provider.clearFilters,
                    backgroundColor: Colors.grey.shade100,
                    avatar: const Icon(Icons.clear_all, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(List<StrategicPlan> plans) {
    final totalPlans = plans.length;
    final activePlans = plans.where((p) => p.status == PlanStatus.active).length;
    final completedGoals = plans.fold(0, (sum, plan) => sum + plan.completedGoals);
    final totalGoals = plans.fold(0, (sum, plan) => sum + plan.totalGoals);
    final avgProgress = plans.isNotEmpty
        ? plans.fold(0.0, (sum, plan) => sum + plan.overallProgress) / plans.length
        : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard(
                  'Total Plans',
                  totalPlans.toString(),
                  Icons.library_books,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active Plans',
                  activePlans.toString(),
                  Icons.play_arrow,
                  Colors.green,
                ),
                _buildStatCard(
                  'Goals Progress',
                  '${((completedGoals / totalGoals) * 100).toStringAsFixed(1)}%',
                  Icons.flag,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Avg. Progress',
                  '${avgProgress.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(StrategicPlanProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Strategic Plans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by creating your first strategic plan to align your organization\'s goals and initiatives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.changeViewMode(ViewMode.create),
              icon: const Icon(Icons.add),
              label: const Text('Create Strategic Plan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(StrategicPlanState state, StrategicPlanProvider provider) {
    if (state.viewMode == ViewMode.list) {
      return FloatingActionButton.extended(
        onPressed: () => provider.changeViewMode(ViewMode.create),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      );
    }
    return null;
  }

  List<String> _getAvailableFiscalYears() {
    final plans = ref.read(strategicPlanProvider).strategicPlans;
    final years = plans.map((p) => p.fiscalYear).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Sort descending
    return years.take(5).toList(); // Limit to 5 most recent years
  }

  Color _getStatusColor(PlanStatus status) {
    switch (status) {
      case PlanStatus.draft:
        return Colors.grey;
      case PlanStatus.underReview:
        return Colors.orange;
      case PlanStatus.approved:
        return Colors.blue;
      case PlanStatus.active:
        return Colors.green;
      case PlanStatus.completed:
        return Colors.purple;
      case PlanStatus.cancelled:
        return Colors.red;
      }
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 4;
    if (width > 600) return 2;
    return 2;
  }
}
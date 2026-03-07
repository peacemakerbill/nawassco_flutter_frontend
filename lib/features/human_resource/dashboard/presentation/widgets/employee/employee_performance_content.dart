import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../../../core/utils/toast_utils.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/performance/performance_appraisal.model.dart';
import '../../../../providers/performance/performance_provider.dart';
import '../sub_widgets/performance/common_widgets/appraisal_card.dart';
import '../sub_widgets/performance/common_widgets/performance_metrics_card.dart';
import '../sub_widgets/performance/details/appraisal_detail_view.dart';
import '../sub_widgets/performance/details/development_plan_view.dart';

class EmployeePerformanceContent extends ConsumerStatefulWidget {
  const EmployeePerformanceContent({super.key});

  @override
  ConsumerState<EmployeePerformanceContent> createState() => _EmployeePerformanceContentState();
}

class _EmployeePerformanceContentState extends ConsumerState<EmployeePerformanceContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PerformanceAppraisal? _selectedAppraisal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load employee appraisals when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.user != null && authState.user!['_id'] != null) {
        ref.read(performanceProvider.notifier).fetchEmployeeAppraisals(authState.user!['_id']);
      }
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
      body: _selectedAppraisal == null ? _buildMainContent(context, performanceState, authState)
          : _buildDetailView(_selectedAppraisal!),
    );
  }

  Widget _buildMainContent(BuildContext context, PerformanceState state, AuthState authState) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Center',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your performance reviews and development',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
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
              Tab(text: 'My Reviews'),
              Tab(text: 'Performance Stats'),
              Tab(text: 'Development Plan'),
              Tab(text: 'Goals'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReviewsTab(state),
              _buildStatsTab(state, authState),
              _buildDevelopmentTab(state),
              _buildGoalsTab(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(PerformanceState state) {
    if (state.isLoading && state.employeeAppraisals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your performance reviews...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.employeeAppraisals.isEmpty) {
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
              'No Performance Reviews Yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your performance reviews will appear here',
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
        final authState = ref.read(authProvider);
        await ref.read(performanceProvider.notifier).fetchEmployeeAppraisals(authState.user!['_id']);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.employeeAppraisals.length,
        itemBuilder: (context, index) {
          final appraisal = state.employeeAppraisals[index];
          return AppraisalCard(
            appraisal: appraisal,
            showActions: appraisal.canAcknowledge,
            onTap: () => _showAppraisalDetail(appraisal),
            onAcknowledge: appraisal.canAcknowledge
                ? () => _showAcknowledgeDialog(appraisal)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(PerformanceState state, AuthState authState) {
    final appraisals = state.employeeAppraisals.where((a) => a.isCompleted).toList();

    if (appraisals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Performance Data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete your first performance review to see statistics',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final completedCount = appraisals.length;
    final averageRating = appraisals
        .map((a) => a.overallRating)
        .fold(0.0, (sum, rating) => sum + rating) / completedCount;

    final highestRating = appraisals
        .map((a) => a.overallRating)
        .fold(0.0, (max, rating) => rating > max ? rating : max);

    final lowestRating = appraisals
        .map((a) => a.overallRating)
        .fold(5.0, (min, rating) => rating < min ? rating : min);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              PerformanceMetricsCard(
                title: 'Total Reviews',
                value: completedCount.toDouble(),
                target: completedCount > 0 ? completedCount.toDouble() : 1,
                color: Colors.blue,
                icon: Icons.receipt_long,
              ),
              PerformanceMetricsCard(
                title: 'Average Rating',
                value: averageRating,
                target: 5.0,
                color: Colors.amber,
                icon: Icons.star,
              ),
              PerformanceMetricsCard(
                title: 'Highest Rating',
                value: highestRating,
                target: 5.0,
                color: Colors.green,
                icon: Icons.trending_up,
              ),
              PerformanceMetricsCard(
                title: 'Lowest Rating',
                value: lowestRating,
                target: 5.0,
                color: Colors.orange,
                icon: Icons.trending_down,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rating Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelRotation: 45,
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 5,
                        interval: 1,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <LineSeries<Map<String, dynamic>, String>>[
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: appraisals.asMap().entries.map((entry) {
                            final appraisal = entry.value;
                            return {
                              'period': appraisal.appraisalPeriod,
                              'rating': appraisal.overallRating,
                              'date': appraisal.appraisalDate,
                            };
                          }).toList(),
                          xValueMapper: (data, _) => data['period'],
                          yValueMapper: (data, _) => data['rating'],
                          name: 'Rating',
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentTab(PerformanceState state) {
    final allPlans = state.employeeAppraisals
        .expand((a) => a.developmentPlan)
        .toList();

    final activePlans = allPlans
        .where((plan) => plan.timeline.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final completedPlans = allPlans
        .where((plan) => plan.timeline.isBefore(DateTime.now()))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Active Plans'),
                Tab(text: 'Completed Plans'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                DevelopmentPlanView(
                  developmentPlans: activePlans,
                  showActions: false,
                ),
                DevelopmentPlanView(
                  developmentPlans: completedPlans,
                  showActions: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(PerformanceState state) {
    final allGoals = state.employeeAppraisals
        .expand((a) => a.goals)
        .toList();

    if (allGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Goals Yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your goals will appear here after performance reviews',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allGoals.length,
      itemBuilder: (context, index) {
        final goal = allGoals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal.goal,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRatingColor(goal.rating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            goal.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRatingColor(goal.rating),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildGoalDetail('Target', goal.target),
                const SizedBox(height: 4),
                _buildGoalDetail('Achievement', goal.achievement),
                if (goal.comments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildGoalDetail('Comments', goal.comments),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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
      isEmployeeView: true,
      onBack: () => setState(() => _selectedAppraisal = null),
      onAcknowledge: appraisal.canAcknowledge ? () => _showAcknowledgeDialog(appraisal) : null,
    );
  }

  void _showAcknowledgeDialog(PerformanceAppraisal appraisal) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acknowledge Performance Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide your comments before acknowledging this review.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your Comments',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your feedback or comments...',
                ),
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
              final comment = commentController.text.trim();
              Navigator.pop(context);
              try {
                await ref.read(performanceProvider.notifier).acknowledgeAppraisal(
                  appraisal.id,
                  comment.isNotEmpty ? comment : 'Employee acknowledged the review',
                );
                ToastUtils.showSuccessToast('Review acknowledged successfully');
              } catch (e) {
                ToastUtils.showErrorToast('Failed to acknowledge review: $e');
              }
            },
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.orange;
    return Colors.red;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../data/providers/analytics_provider.dart';
import '../../data/models/news_analytics.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  String _selectedGroupBy = 'day';

  final List<String> _periods = ['1d', '7d', '30d', '90d'];
  final List<String> _groupByOptions = ['day', 'week', 'month'];
  final List<String> _tabTitles = [
    'Overview',
    'Content',
    'Audience',
    'Traffic'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    await ref.read(analyticsProvider.notifier).fetchOverallAnalytics(
          period: _selectedPeriod,
          groupBy: _selectedGroupBy,
        );
  }

  Future<void> _loadAuthorAnalytics() async {
    await ref.read(analyticsProvider.notifier).fetchAuthorAnalytics(
          period: _selectedPeriod,
        );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadAnalytics();
  }

  void _onGroupByChanged(String groupBy) {
    setState(() {
      _selectedGroupBy = groupBy;
    });
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?['roles']?.contains('Admin') ?? false;
    final isManager = user?['roles']?.contains('Manager') ?? false;
    final canViewAnalytics = isAdmin || isManager;

    if (!canViewAnalytics) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Analytics Access Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You need admin or manager privileges\nto access analytics',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header with filters
          _buildHeader(),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(analyticsState),
                  _buildContentTab(analyticsState),
                  _buildAudienceTab(analyticsState),
                  _buildTrafficTab(analyticsState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'News Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track performance and engagement',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Period selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Period',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      items: _periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(_getPeriodLabel(period)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _onPeriodChanged(value);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Group by selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Group By',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedGroupBy,
                      items: _groupByOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _onGroupByChanged(value);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    return switch (period) {
      '1d' => 'Last 24 Hours',
      '7d' => 'Last 7 Days',
      '30d' => 'Last 30 Days',
      '90d' => 'Last 90 Days',
      _ => period,
    };
  }

  Widget _buildOverviewTab(AnalyticsState state) {
    final summary = state.overallSummary;
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          _buildKeyMetrics(summary),
          const SizedBox(height: 24),

          // Trends Chart
          if (state.overallTrends.isNotEmpty)
            _buildTrendsChart(state.overallTrends),
          const SizedBox(height: 24),

          // Top Performing Content
          if (state.popularNews.isNotEmpty)
            _buildPopularNews(state.popularNews),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(AnalyticsSummary summary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Views',
          summary.totalViews.toString(),
          Icons.remove_red_eye,
          Colors.blue,
        ),
        _buildMetricCard(
          'Unique Views',
          summary.totalUniqueViews.toString(),
          Icons.people,
          Colors.green,
        ),
        _buildMetricCard(
          'Engagement Rate',
          '${summary.engagementRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.purple,
        ),
        _buildMetricCard(
          'Avg. Time Spent',
          '${summary.averageTimeSpent.toStringAsFixed(0)}s',
          Icons.timer,
          Colors.orange,
        ),
        _buildMetricCard(
          'Total Likes',
          summary.totalLikes.toString(),
          Icons.thumb_up,
          Colors.red,
        ),
        _buildMetricCard(
          'Total Shares',
          summary.totalShares.toString(),
          Icons.share,
          Colors.teal,
        ),
        _buildMetricCard(
          'Total Comments',
          summary.totalComments.toString(),
          Icons.comment,
          Colors.amber,
        ),
        _buildMetricCard(
          'Bounce Rate',
          '${summary.averageBounceRate.toStringAsFixed(1)}%',
          Icons.exit_to_app,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 4),
                const Text(
                  '+12%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(List<TrendData> trends) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Trends',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <LineSeries<TrendData, String>>[
                  LineSeries<TrendData, String>(
                    name: 'Views',
                    dataSource: trends,
                    xValueMapper: (TrendData data, _) => data.date,
                    yValueMapper: (TrendData data, _) => data.views,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<TrendData, String>(
                    name: 'Likes',
                    dataSource: trends,
                    xValueMapper: (TrendData data, _) => data.date,
                    yValueMapper: (TrendData data, _) => data.likes,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<TrendData, String>(
                    name: 'Comments',
                    dataSource: trends,
                    xValueMapper: (TrendData data, _) => data.date,
                    yValueMapper: (TrendData data, _) => data.comments,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<TrendData, String>(
                    name: 'Shares',
                    dataSource: trends,
                    xValueMapper: (TrendData data, _) => data.date,
                    yValueMapper: (TrendData data, _) => data.shares,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularNews(List<dynamic> popularNews) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            ...popularNews
                .take(5)
                .map((news) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: news['featuredImage'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      news['featuredImage'],
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.article, color: Colors.grey),
                          ),
                          title: Text(
                            news['title'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${news['views'] ?? 0} views • ${news['engagementScore'] ?? 0} engagement',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${news['engagementScore'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const Text(
                                'Score',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab(AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category Performance
          if (state.categoryPerformance.isNotEmpty)
            _buildCategoryPerformance(state.categoryPerformance),

          const SizedBox(height: 24),

          // Author Performance
          if (state.authorPerformance.isNotEmpty)
            _buildAuthorPerformance(state.authorPerformance),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformance(List<dynamic> categories) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <BarSeries<dynamic, String>>[
                  BarSeries<dynamic, String>(
                    dataSource: categories.take(10).toList(),
                    xValueMapper: (data, _) => data['name'] ?? 'Unknown',
                    yValueMapper: (data, _) => data['totalViews'] ?? 0,
                    name: 'Views',
                    color: const Color(0xFF0D47A1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...categories
                .take(5)
                .map((category) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(category['name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${category['newsCount'] ?? 0} articles • ${category['totalViews'] ?? 0} views',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${category['avgViews']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const Text(
                                'Avg Views',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorPerformance(List<dynamic> authors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Author Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            ...authors
                .take(10)
                .map((author) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(author['name'] ?? 'Unknown'),
                          subtitle: Text(
                            '@${author['username'] ?? 'unknown'} • ${author['newsCount'] ?? 0} articles',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${author['totalViews'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const Text(
                                'Views',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceTab(AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Device Distribution
          _buildDeviceDistribution(),
          const SizedBox(height: 24),

          // Demographics
          _buildDemographics(),
        ],
      ),
    );
  }

  Widget _buildDeviceDistribution() {
    final distribution = {
      'mobile': 65.2,
      'desktop': 28.7,
      'tablet': 6.1,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(isVisible: true),
                series: <PieSeries<MapEntry<String, double>, String>>[
                  PieSeries<MapEntry<String, double>, String>(
                    dataSource: distribution.entries.toList(),
                    xValueMapper: (MapEntry<String, double> data, _) =>
                        data.key,
                    yValueMapper: (MapEntry<String, double> data, _) =>
                        data.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audience Demographics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildDemographicCard('Age Groups', [
                  {'group': '18-24', 'value': 32},
                  {'group': '25-34', 'value': 45},
                  {'group': '35-44', 'value': 15},
                  {'group': '45+', 'value': 8},
                ]),
                _buildDemographicCard('Gender', [
                  {'group': 'Male', 'value': 58},
                  {'group': 'Female', 'value': 39},
                  {'group': 'Other', 'value': 3},
                ]),
                _buildDemographicCard('Locations', [
                  {'group': 'Nairobi', 'value': 42},
                  {'group': 'Mombasa', 'value': 18},
                  {'group': 'Kisumu', 'value': 12},
                  {'group': 'Others', 'value': 28},
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicCard(String title, List<Map<String, dynamic>> data) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...data
                .map((item) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['group'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              '${item['value']}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: item['value'] / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(item['value']),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value > 40) return Colors.green;
    if (value > 20) return Colors.blue;
    return Colors.orange;
  }

  Widget _buildTrafficTab(AnalyticsState state) {
    final sources = {
      'direct': 35.2,
      'social': 28.7,
      'search': 25.4,
      'referral': 10.7,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Traffic Sources
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Traffic Sources',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCircularChart(
                      legend: Legend(isVisible: true),
                      series: <DoughnutSeries<MapEntry<String, double>,
                          String>>[
                        DoughnutSeries<MapEntry<String, double>, String>(
                          dataSource: sources.entries.toList(),
                          xValueMapper: (MapEntry<String, double> data, _) =>
                              data.key,
                          yValueMapper: (MapEntry<String, double> data, _) =>
                              data.value,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sources.entries
                      .map((source) => Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: _getSourceIcon(source.key),
                                title: Text(
                                  _getSourceLabel(source.key),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: Text(
                                  '${source.value.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSourceIcon(String source) {
    return switch (source) {
      'direct' => const Icon(Icons.directions, color: Colors.blue),
      'social' => const Icon(Icons.people, color: Colors.green),
      'search' => const Icon(Icons.search, color: Colors.orange),
      'referral' => const Icon(Icons.link, color: Colors.purple),
      _ => const Icon(Icons.public, color: Colors.grey),
    };
  }

  String _getSourceLabel(String source) {
    return switch (source) {
      'direct' => 'Direct Traffic',
      'social' => 'Social Media',
      'search' => 'Search Engines',
      'referral' => 'Referral Sites',
      _ => source,
    };
  }
}

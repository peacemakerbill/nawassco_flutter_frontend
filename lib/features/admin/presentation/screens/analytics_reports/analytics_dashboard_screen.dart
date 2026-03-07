import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/admin_colors.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            border: Border(bottom: BorderSide(color: AdminColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics & Reports',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comprehensive analytics and reporting for business insights',
                style: TextStyle(
                  color: AdminColors.textSecondary,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: AdminColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AdminColors.primary,
            unselectedLabelColor: AdminColors.textSecondary,
            indicatorColor: AdminColors.primary,
            isScrollable: MediaQuery.of(context).size.width < 600,
            tabs: const [
              Tab(text: 'Usage Analytics'),
              Tab(text: 'Financial Reports'),
              Tab(text: 'Operational Reports'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              UsageAnalyticsTab(),
              FinancialReportsTab(),
              OperationalReportsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class UsageAnalyticsTab extends StatelessWidget {
  const UsageAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final crossAxisCount = isLargeScreen ? 3 : 1;
        final padding = isLargeScreen ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Usage Metrics
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isLargeScreen ? 1.2 : 1.5,
                children: [
                  _AnalyticsCard(
                    title: 'Avg. Daily Usage',
                    value: '0.6m³',
                    change: '-5%',
                    color: AdminColors.success,
                  ),
                  _AnalyticsCard(
                    title: 'Peak Usage Time',
                    value: '7-9 AM',
                    change: 'Consistent',
                    color: AdminColors.info,
                  ),
                  _AnalyticsCard(
                    title: 'Conservation Rate',
                    value: '12%',
                    change: '+3%',
                    color: AdminColors.primary,
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 32 : 24),

              // Usage Charts
              isLargeScreen
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ChartCard(
                      title: 'Daily Usage Pattern',
                      content: 'Daily Usage Chart',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _ChartCard(
                      title: 'Monthly Consumption',
                      content: 'Monthly Chart',
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  _ChartCard(
                    title: 'Daily Usage Pattern',
                    content: 'Daily Usage Chart',
                  ),
                  SizedBox(height: 16),
                  _ChartCard(
                    title: 'Monthly Consumption',
                    content: 'Monthly Chart',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class FinancialReportsTab extends StatelessWidget {
  const FinancialReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 24 : 16,
            vertical: constraints.maxWidth > 600 ? 24 : 16,
          ),
          child: const Center(
            child: Text('Financial Reports Content'),
          ),
        );
      },
    );
  }
}

class OperationalReportsTab extends StatelessWidget {
  const OperationalReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 24 : 16,
            vertical: constraints.maxWidth > 600 ? 24 : 16,
          ),
          child: const Center(
            child: Text('Operational Reports Content'),
          ),
        );
      },
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.analytics, color: color, size: 18),
                ),
                Flexible(
                  child: Text(
                    change,
                    style: TextStyle(
                      color: change.startsWith('+') ? AdminColors.success :
                      change.startsWith('-') ? AdminColors.error : AdminColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String content;

  const _ChartCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isLargeScreen ? 250 : 200,
              child: Center(
                child: Text(content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
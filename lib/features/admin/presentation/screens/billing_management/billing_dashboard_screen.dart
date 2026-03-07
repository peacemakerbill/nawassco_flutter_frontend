import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/admin_colors.dart';

class BillingDashboardScreen extends ConsumerStatefulWidget {
  const BillingDashboardScreen({super.key});

  @override
  ConsumerState<BillingDashboardScreen> createState() => _BillingDashboardScreenState();
}

class _BillingDashboardScreenState extends ConsumerState<BillingDashboardScreen> with SingleTickerProviderStateMixin {
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
                'Billing & Revenue Management',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage customer controller, payments, and revenue analytics',
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
              Tab(text: 'Revenue Overview'),
              Tab(text: 'Billing History'),
              Tab(text: 'Payment Analytics'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              RevenueOverviewTab(),
              BillingHistoryTab(),
              PaymentAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class RevenueOverviewTab extends StatelessWidget {
  const RevenueOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final crossAxisCount = isLargeScreen ? 4 : 2;
        final padding = isLargeScreen ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Revenue Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isLargeScreen ? 1.1 : 1.3,
                children: [
                  _RevenueCard(
                    title: 'Total Revenue',
                    value: 'KES 1,250,000',
                    change: '+12%',
                    color: AdminColors.success,
                  ),
                  _RevenueCard(
                    title: 'Collections',
                    value: 'KES 980,000',
                    change: '+8%',
                    color: AdminColors.primary,
                  ),
                  _RevenueCard(
                    title: 'Outstanding',
                    value: 'KES 270,000',
                    change: '-5%',
                    color: AdminColors.warning,
                  ),
                  _RevenueCard(
                    title: 'Avg. Bill',
                    value: 'KES 1,250',
                    change: '+3%',
                    color: AdminColors.info,
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 32 : 24),

              // Revenue Chart
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Trend',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: isLargeScreen ? 300 : 200,
                        child: const Center(
                          child: Text('Revenue Chart Placeholder'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BillingHistoryTab extends StatelessWidget {
  const BillingHistoryTab({super.key});

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
            child: Text('Billing History Content'),
          ),
        );
      },
    );
  }
}

class PaymentAnalyticsTab extends StatelessWidget {
  const PaymentAnalyticsTab({super.key});

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
            child: Text('Payment Analytics Content'),
          ),
        );
      },
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;

  const _RevenueCard({
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
                  child: Icon(Icons.attach_money, color: color, size: 18),
                ),
                Flexible(
                  child: Text(
                    change,
                    style: TextStyle(
                      color: change.startsWith('+') ? AdminColors.success : AdminColors.error,
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
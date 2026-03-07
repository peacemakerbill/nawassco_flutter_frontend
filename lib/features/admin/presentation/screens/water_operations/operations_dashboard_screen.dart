import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/admin_colors.dart';

class OperationsDashboardScreen extends ConsumerStatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  ConsumerState<OperationsDashboardScreen> createState() => _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends ConsumerState<OperationsDashboardScreen> with SingleTickerProviderStateMixin {
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
                'Water Operations',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor water production, quality, and distribution',
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
              Tab(text: 'Production'),
              Tab(text: 'Quality'),
              Tab(text: 'Maintenance'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ProductionTab(),
              QualityTab(),
              MaintenanceTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductionTab extends StatelessWidget {
  const ProductionTab({super.key});

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
              // Production Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isLargeScreen ? 1.2 : 1.5,
                children: [
                  _ProductionCard(
                    title: 'Daily Production',
                    value: '45,000 m³',
                    status: 'Normal',
                    color: AdminColors.success,
                  ),
                  _ProductionCard(
                    title: 'Reservoir Levels',
                    value: '78%',
                    status: 'Good',
                    color: AdminColors.info,
                  ),
                  _ProductionCard(
                    title: 'Treatment Plants',
                    value: '3/4 Active',
                    status: '1 Down',
                    color: AdminColors.warning,
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 32 : 24),

              // Production Chart
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Production Overview',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: isLargeScreen ? 300 : 200,
                        child: const Center(
                          child: Text('Production Chart Placeholder'),
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

class QualityTab extends StatelessWidget {
  const QualityTab({super.key});

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
            child: Text('Water Quality Monitoring Content'),
          ),
        );
      },
    );
  }
}

class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({super.key});

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
            child: Text('Maintenance Schedule Content'),
          ),
        );
      },
    );
  }
}

class _ProductionCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final Color color;

  const _ProductionCard({
    required this.title,
    required this.value,
    required this.status,
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
                  child: Icon(Icons.water_drop, color: color, size: 18),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
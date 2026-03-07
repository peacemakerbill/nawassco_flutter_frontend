import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../models/opportunity.model.dart';
import '../../../../providers/opportunity_provider.dart';

class OpportunityStatsCard extends ConsumerWidget {
  const OpportunityStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(opportunityProvider);
    final stats = state.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.insights, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Opportunity Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref.read(opportunityProvider.notifier).refreshData(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Responsive Stats Grid - Fixed for all screen sizes
          LayoutBuilder(builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            // Determine number of columns based on screen width
            int crossAxisCount;
            if (screenWidth < 600) {
              // Small screens: 1 column
              crossAxisCount = 1;
            } else if (screenWidth < 900) {
              // Medium screens: 2 columns
              crossAxisCount = 2;
            } else if (screenWidth < 1200) {
              // Large screens: 3 columns
              crossAxisCount = 3;
            } else {
              // Extra large screens: 4 columns
              crossAxisCount = 4;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: _getChildAspectRatio(screenWidth),
              children: [
                _buildCard('Total Opportunities', '${stats.total}', Icons.business_center, Colors.blue),
                _buildCard('Total Value', stats.totalValueFormatted, Icons.attach_money, Colors.green),
                _buildCard('Expected Revenue', stats.expectedRevenueFormatted, Icons.trending_up, Colors.orange),
                _buildCard('Win Rate', stats.winRateFormatted, Icons.star, Colors.purple),
              ],
            );
          }),

          const SizedBox(height: 30),

          // Stage Distribution Chart - Also make this responsive
          const Text(
            'Opportunities by Stage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxWidth < 600 ? 180 : 200, // Adjust height for small screens
              width: double.infinity,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(
                    fontSize: constraints.maxWidth < 600 ? 10 : 12,
                  ),
                ),
                primaryYAxis: const NumericAxis(labelStyle: TextStyle(fontSize: 12)),
                series: <ColumnSeries<StageStat, String>>[
                  ColumnSeries<StageStat, String>(
                    dataSource: stats.byStage,
                    xValueMapper: (StageStat data, _) => data.stage.displayName,
                    yValueMapper: (StageStat data, _) => data.count,
                    pointColorMapper: (StageStat data, _) => data.stage.color,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontSize: constraints.maxWidth < 600 ? 8 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Calculate aspect ratio based on screen width for better card proportions
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 3.5; // Wider cards for single column
    } else if (screenWidth < 900) {
      return 2.5; // Medium aspect ratio for 2 columns
    } else if (screenWidth < 1200) {
      return 2.0; // Square-ish for 3 columns
    } else {
      return 1.8; // More rectangular for 4 columns
    }
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
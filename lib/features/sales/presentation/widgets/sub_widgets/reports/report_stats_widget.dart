import 'package:flutter/material.dart';
import '../../../../models/report.model.dart';
import 'responsive.dart';

class ReportStatsWidget extends StatelessWidget {
  final ReportStats stats;

  const ReportStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reports Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            isMobile ? _buildMobileLayout() : isTablet ? _buildTabletLayout() : _buildDesktopLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildStatsGrid(2),
      const SizedBox(height: 16),
      _buildSalesCard(isVertical: true),
      const SizedBox(height: 16),
      _buildTypeDistribution(),
    ],
  );

  Widget _buildTabletLayout() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildStatsGrid(3)),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildSalesCard(isVertical: true)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildTypeDistribution(),
    ],
  );

  Widget _buildDesktopLayout() => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 200, maxHeight: 300),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: SingleChildScrollView(child: _buildDesktopStats())),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildDesktopSales()),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildTypeDistribution()),
        ],
      ),
    ),
  );

  Widget _buildStatsGrid(int columns) {
    final List<Map<String, dynamic>> statItems = [
      {'title': 'Total', 'value': stats.total, 'color': Colors.blue},
      {'title': 'Draft', 'value': stats.draft, 'color': Colors.orange},
      {'title': 'Submitted', 'value': stats.submitted, 'color': Colors.green},
      {'title': 'Approved', 'value': stats.approved, 'color': Colors.teal},
      {'title': 'Rejected', 'value': stats.rejected, 'color': Colors.red},
      {'title': 'Pending Review', 'value': stats.pendingReview, 'color': Colors.amber},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statItems.map((item) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 180),
        child: _buildStatCard(item['title'], item['value'], item['color']),
      )).toList(),
    );
  }

  Widget _buildDesktopStats() => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      _buildStatCard('Total Reports', stats.total, Colors.blue),
      _buildStatCard('Draft', stats.draft, Colors.orange),
      _buildStatCard('Submitted', stats.submitted, Colors.green),
      _buildStatCard('Approved', stats.approved, Colors.teal),
      _buildStatCard('Rejected', stats.rejected, Colors.red),
      _buildStatCard('Pending Review', stats.pendingReview, Colors.amber),
    ],
  );

  Widget _buildSalesCard({required bool isVertical}) => Card(
    color: Colors.indigo[50],
    child: Padding(padding: const EdgeInsets.all(12), child: isVertical ? _buildVerticalSales() : _buildHorizontalSales()),
  );

  Widget _buildVerticalSales() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildSalesItem(icon: Icons.attach_money, color: Colors.indigo, title: 'Total Sales Value', value: 'KES ${stats.totalSalesValue.toStringAsFixed(2)}', bgColor: Colors.indigo[100]!),
      const SizedBox(height: 8),
      _buildSalesItem(icon: Icons.star, color: Colors.teal, title: 'Average Quality Score', value: '${stats.averageQualityScore.toStringAsFixed(1)}/100', bgColor: Colors.teal[100]!),
    ],
  );

  Widget _buildHorizontalSales() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigo[100], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.attach_money, color: Colors.indigo)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Sales Value', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text('KES ${stats.totalSalesValue.toStringAsFixed(2)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    ],
  );

  Widget _buildDesktopSales() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildDesktopSalesCard(icon: Icons.attach_money, color: Colors.indigo, title: 'Total Sales', value: 'KES ${stats.totalSalesValue.toStringAsFixed(2)}', bgColor: Colors.indigo[100]!),
      const SizedBox(height: 8),
      _buildDesktopSalesCard(icon: Icons.star, color: Colors.teal, title: 'Avg Quality', value: '${stats.averageQualityScore.toStringAsFixed(1)}/100', bgColor: Colors.teal[100]!),
    ],
  );

  Widget _buildStatCard(String title, int value, Color color) => Container(
    padding: const EdgeInsets.all(10),
    constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value.toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const Spacer(),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Icon(_getStatIcon(title), size: 14, color: color)),
          ],
        ),
      ],
    ),
  );

  Widget _buildSalesItem({required IconData icon, required Color color, required String title, required String value, required Color bgColor}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    ],
  );

  Widget _buildDesktopSalesCard({required IconData icon, required Color color, required String title, required String value, required Color bgColor}) => Card(
    color: color.withOpacity(0.05),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 28, color: color)),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    ),
  );

  Widget _buildTypeDistribution() {
    final total = stats.byType.values.fold(0, (sum, count) => sum + count);
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Types', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            ...stats.byType.entries.where((entry) => entry.value > 0).map((entry) => _buildTypeRow(entry.key.displayName, entry.value, total)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRow(String type, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              Text('$count (${percentage.toStringAsFixed(1)}%)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor(type)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  IconData _getStatIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('total')) return Icons.summarize;
    if (lowerTitle.contains('draft')) return Icons.edit;
    if (lowerTitle.contains('submitted')) return Icons.send;
    if (lowerTitle.contains('approved')) return Icons.check_circle;
    if (lowerTitle.contains('rejected')) return Icons.cancel;
    if (lowerTitle.contains('pending')) return Icons.access_time;
    return Icons.analytics;
  }

  Color _getTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('daily')) return Colors.blue;
    if (lowerType.contains('weekly')) return Colors.green;
    if (lowerType.contains('monthly')) return Colors.orange;
    if (lowerType.contains('quarterly')) return Colors.purple;
    if (lowerType.contains('yearly')) return Colors.red;
    if (lowerType.contains('ad-hoc')) return Colors.teal;
    if (lowerType.contains('activity')) return Colors.indigo;
    if (lowerType.contains('performance')) return Colors.amber;
    return Colors.grey;
  }
}
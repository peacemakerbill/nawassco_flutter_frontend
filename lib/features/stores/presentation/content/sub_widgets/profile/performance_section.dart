import 'package:flutter/material.dart';
import '../../../../models/store_manager_model.dart';

class PerformanceSection extends StatelessWidget {
  final StoreManager storeManager;

  const PerformanceSection({super.key, required this.storeManager});

  @override
  Widget build(BuildContext context) {
    final performance = storeManager.performance;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Overall Performance Card
          _buildOverallPerformanceCard(performance),
          const SizedBox(height: 16),

          // Detailed Metrics Card
          _buildDetailedMetricsCard(performance),
          const SizedBox(height: 16),

          // Key Result Areas Card
          _buildKeyResultAreasCard(),
          const SizedBox(height: 16),

          // Review Dates Card
          _buildReviewDatesCard(performance),
        ],
      ),
    );
  }

  Widget _buildOverallPerformanceCard(StoreManagerPerformance performance) {
    Color overallColor;
    String overallStatus;

    if (performance.overallRating >= 80) {
      overallColor = Colors.green;
      overallStatus = 'Excellent';
    } else if (performance.overallRating >= 70) {
      overallColor = Colors.blue;
      overallStatus = 'Good';
    } else if (performance.overallRating >= 60) {
      overallColor = Colors.orange;
      overallStatus = 'Satisfactory';
    } else {
      overallColor = Colors.red;
      overallStatus = 'Needs Improvement';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader('Overall Performance', Icons.assessment),
            const SizedBox(height: 16),

            // Overall Rating Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: performance.overallRating / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    color: overallColor,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${performance.overallRating.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: overallColor,
                      ),
                    ),
                    Text(
                      overallStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: overallColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Performance Indicators
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildPerformanceIndicator('Inventory Accuracy',
                    performance.inventoryAccuracy, Icons.inventory),
                _buildPerformanceIndicator('Stock Turnover',
                    performance.stockTurnover, Icons.autorenew),
                _buildPerformanceIndicator('Order Fulfillment',
                    performance.orderFulfillment, Icons.local_shipping),
                _buildPerformanceIndicator('Cost Savings',
                    performance.costSavings, Icons.savings),
                _buildPerformanceIndicator('Team Performance',
                    performance.teamPerformance, Icons.people),
                _buildPerformanceIndicator('Safety Compliance',
                    performance.safetyCompliance, Icons.security),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsCard(StoreManagerPerformance performance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Detailed Performance Metrics', Icons.analytics),
            const SizedBox(height: 16),

            _buildPerformanceMetricRow('Inventory Accuracy', performance.inventoryAccuracy),
            _buildPerformanceMetricRow('Stock Turnover', performance.stockTurnover),
            _buildPerformanceMetricRow('Order Fulfillment', performance.orderFulfillment),
            _buildPerformanceMetricRow('Cost Savings', performance.costSavings),
            _buildPerformanceMetricRow('Team Performance', performance.teamPerformance),
            _buildPerformanceMetricRow('Safety Compliance', performance.safetyCompliance),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyResultAreasCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Key Result Areas (KRAs)', Icons.flag),
            const SizedBox(height: 16),

            if (storeManager.keyResultAreas.isEmpty)
              const Center(
                child: Text(
                  'No key result areas defined',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...storeManager.keyResultAreas.map((kra) =>
                  _buildKRAItem(kra),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDatesCard(StoreManagerPerformance performance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Performance Reviews', Icons.calendar_today),
            const SizedBox(height: 16),

            _buildReviewDateRow('Last Review', performance.lastReviewDate),
            _buildReviewDateRow('Next Review', performance.nextReviewDate),

            const SizedBox(height: 16),
            _buildDaysUntilNextReview(performance.nextReviewDate),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(String title, double value, IconData icon) {
    Color color;
    if (value >= 80) {
      color = Colors.green;
    } else if (value >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricRow(String label, double value) {
    Color color;
    if (value >= 80) {
      color = Colors.green;
    } else if (value >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      _getPerformanceStatus(value),
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKRAItem(StoreKRA kra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kra.area,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Chip(
                label: Text('Weight: ${kra.weight}%'),
                backgroundColor: Colors.blue[50],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // KRA Performance
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: kra.performance / 100,
                  backgroundColor: Colors.grey[200],
                  color: kra.performance >= 80 ? Colors.green :
                  kra.performance >= 60 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${kra.performance.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          if (kra.metrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Metrics:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ...kra.metrics.map((metric) =>
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${metric.metric}: ${metric.actual}/${metric.target} ${metric.unit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        metric.frequency,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              date.toIso8601String().split('T')[0],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysUntilNextReview(DateTime nextReview) {
    final now = DateTime.now();
    final difference = nextReview.difference(now);
    final daysUntil = difference.inDays;

    Color color;
    String status;

    if (daysUntil < 0) {
      color = Colors.red;
      status = 'Overdue';
    } else if (daysUntil <= 7) {
      color = Colors.orange;
      status = 'Due Soon';
    } else if (daysUntil <= 30) {
      color = Colors.blue;
      status = 'Upcoming';
    } else {
      color = Colors.green;
      status = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Days until next review:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            daysUntil < 0 ? '${daysUntil.abs()} days overdue' : '$daysUntil days',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPerformanceStatus(double value) {
    if (value >= 80) return 'Excellent';
    if (value >= 70) return 'Good';
    if (value >= 60) return 'Satisfactory';
    return 'Needs Improvement';
  }
}
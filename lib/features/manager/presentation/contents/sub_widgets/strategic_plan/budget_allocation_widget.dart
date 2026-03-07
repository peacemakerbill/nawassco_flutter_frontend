import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../../../models/strategic_plan_model.dart';

class BudgetAllocationWidget extends StatelessWidget {
  final StrategicPlan plan;

  const BudgetAllocationWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final allocations = plan.budgetAllocation;
    final totalBudget = _calculateTotalBudget();
    final totalSpent = _calculateTotalSpent();
    final utilization = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Budget Allocation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildBudgetSummary(
                    totalBudget, totalSpent, utilization.toDouble()),
              ],
            ),
            const SizedBox(height: 20),
            if (allocations.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.pie_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No budget allocations defined',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Pie Chart Visualization
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildPieChart(allocations),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildLegend(allocations),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Budget Breakdown
                  _buildBudgetBreakdown(allocations),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(
      double totalBudget, double totalSpent, double utilization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${totalBudget.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        Text(
          'Total Budget',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${totalSpent.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
        Text(
          'Total Spent',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${utilization.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getUtilizationColor(utilization),
          ),
        ),
        Text(
          'Utilization',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> allocations) {
    final colors = _getChartColors(allocations.length);
    double startAngle = 0;

    return CustomPaint(
      size: const Size(200, 200),
      painter: _PieChartPainter(
        allocations: allocations,
        colors: colors,
        startAngle: startAngle,
      ),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> allocations) {
    final colors = _getChartColors(allocations.length);
    final totalBudget = _calculateTotalBudget();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allocations.length,
      itemBuilder: (context, index) {
        final allocation = allocations[index];
        final amount = (allocation['allocated'] ?? 0).toDouble();
        final spent = (allocation['spent'] ?? 0).toDouble();
        final percentage = totalBudget > 0 ? (amount / totalBudget) * 100 : 0;
        final utilization = amount > 0 ? (spent / amount) * 100 : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allocation['category'] ?? 'Uncategorized',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Allocated: \$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${spent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${utilization.toStringAsFixed(1)}% spent',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getUtilizationColor(utilization),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetBreakdown(List<Map<String, dynamic>> allocations) {
    final totalBudget = _calculateTotalBudget();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Breakdown',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ...allocations.map((allocation) {
          final amount = (allocation['allocated'] ?? 0).toDouble();
          final spent = (allocation['spent'] ?? 0).toDouble();
          final percentage = totalBudget > 0 ? (amount / totalBudget) * 100 : 0;
          final remaining = amount - spent;
          final utilization = amount > 0 ? (spent / amount) * 100 : 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        allocation['category'] ?? 'Uncategorized',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    allocation['description'] ?? 'No description',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent: \$${spent.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Remaining: \$${remaining.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          // Background
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),

                          // Spent amount
                          Container(
                            height: 10,
                            width: utilization.clamp(0, 100) /
                                100 *
                                (MediaQuery.of(context as BuildContext)
                                        .size
                                        .width -
                                    64),
                            decoration: BoxDecoration(
                              color: _getUtilizationColor(utilization),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${utilization.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getUtilizationColor(utilization),
                            ),
                          ),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Owner and Timeline
                  Row(
                    children: [
                      _buildDetailItem(
                        Icons.person,
                        allocation['owner'] ?? 'Unassigned',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildDetailItem(
                        Icons.calendar_today,
                        _formatDateRange(allocation),
                        Colors.orange,
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  double _calculateTotalBudget() {
    return plan.budgetAllocation.fold(0.0, (sum, item) {
      return sum + (item['allocated'] ?? 0).toDouble();
    });
  }

  double _calculateTotalSpent() {
    return plan.budgetAllocation.fold(0.0, (sum, item) {
      return sum + (item['spent'] ?? 0).toDouble();
    });
  }

  List<Color> _getChartColors(int count) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    return colors.take(count).toList();
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization <= 70) return Colors.green;
    if (utilization <= 90) return Colors.orange;
    return Colors.red;
  }

  String _formatDateRange(Map<String, dynamic> allocation) {
    final start = allocation['startDate'];
    final end = allocation['endDate'];

    if (start == null || end == null) return 'No timeline';

    return '${_formatDateShort(start)} - ${_formatDateShort(end)}';
  }

  String _formatDateShort(dynamic date) {
    if (date is String) {
      final dateTime = DateTime.tryParse(date);
      if (dateTime != null) {
        return '${dateTime.month}/${dateTime.day}';
      }
    }
    return '';
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> allocations;
  final List<Color> colors;
  final double startAngle;

  _PieChartPainter({
    required this.allocations,
    required this.colors,
    this.startAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    final total = allocations.fold(0.0, (sum, item) {
      return sum + (item['allocated'] ?? 0).toDouble();
    });

    if (total == 0) return;

    double currentAngle = startAngle;

    for (int i = 0; i < allocations.length; i++) {
      final allocation = allocations[i];
      final amount = (allocation['allocated'] ?? 0).toDouble();
      final sweepAngle = (amount / total) * 2 * 3.14159;
      final spent = (allocation['spent'] ?? 0).toDouble();
      final utilization = amount > 0 ? (spent / amount) : 0;

      // Draw pie slice
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw spent portion
      if (utilization > 0) {
        final spentPaint = Paint()
          ..color = colors[i].withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.7),
          currentAngle,
          sweepAngle * utilization,
          true,
          spentPaint,
        );
      }

      // Draw outline
      final outlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        outlinePaint,
      );

      currentAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

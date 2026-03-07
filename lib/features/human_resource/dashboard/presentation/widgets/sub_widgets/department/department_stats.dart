import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../providers/department_provider.dart';
import '../../../../../utils/department_constants.dart';

class DepartmentStatsWidget extends ConsumerWidget {
  const DepartmentStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(departmentProvider);
    final stats = state.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  title: 'Total Departments',
                  value: stats.totalDepartments.toString(),
                  icon: Icons.business,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Active Departments',
                  value: stats.activeDepartments.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Inactive Departments',
                  value: (stats.totalDepartments - stats.activeDepartments).toString(),
                  icon: Icons.pause_circle,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Active Rate',
                  value: '${((stats.activeDepartments / stats.totalDepartments) * 100).toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Employee Distribution Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Distribution by Department',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxEmployeeCount(stats.departmentEmployeeStats) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final deptName = stats.departmentEmployeeStats[groupIndex]['_id'] ?? 'Unknown';
                                final count = rod.toY.toInt();
                                return BarTooltipItem(
                                  '$deptName\n$count employees',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= stats.departmentEmployeeStats.length) {
                                    return const SizedBox();
                                  }
                                  final deptName = stats.departmentEmployeeStats[value.toInt()]['_id'] ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                      width: 80,
                                      child: Text(
                                        deptName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: const Color(0xff37434d), width: 1),
                          ),
                          barGroups: stats.departmentEmployeeStats.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stat = entry.value;
                            final color = _parseColor(DepartmentConstants.getDepartmentColor(stat['_id'] ?? '') as String);

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (stat['employeeCount'] ?? 0).toDouble(),
                                  width: 20,
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: _getMaxEmployeeCount(stats.departmentEmployeeStats),
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Budget Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.departmentBudgetStats.length,
                      itemBuilder: (context, index) {
                        final dept = stats.departmentBudgetStats[index];
                        final budget = (dept['budget'] ?? 0).toDouble();
                        final maxBudget = stats.departmentBudgetStats
                            .map((d) => (d['budget'] ?? 0).toDouble())
                            .reduce((a, b) => a > b ? a : b);
                        final percentage = maxBudget > 0 ? (budget / maxBudget) * 100 : 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dept['name'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'KES ${budget.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                // color: DepartmentConstants.getDepartmentColor(dept['name'] ?? ''),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Department List Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Department')),
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Employees'), numeric: true),
                          DataColumn(label: Text('Budget (KES)'), numeric: true),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: stats.departmentEmployeeStats.map((stat) {
                          final deptBudget = stats.departmentBudgetStats.firstWhere(
                                (b) => b['_id'] == stat['_id'],
                            orElse: () => {'budget': 0},
                          );

                          return DataRow(cells: [
                            DataCell(Text(stat['_id'] ?? 'Unknown')),
                            DataCell(Text(
                              DepartmentConstants.departmentTemplates
                                  .firstWhere(
                                    (t) => t['name'] == stat['_id'],
                                orElse: () => {'code': 'N/A'},
                              )['code'],
                            )),
                            DataCell(Text('${stat['employeeCount'] ?? 0}')),
                            DataCell(Text('${deptBudget['budget']?.toStringAsFixed(0) ?? '0'}')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (stat['isActive'] ?? true)
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (stat['isActive'] ?? true) ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: (stat['isActive'] ?? true)
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxEmployeeCount(List<dynamic> stats) {
    if (stats.isEmpty) return 0;
    return stats
        .map<double>((stat) => (stat['employeeCount'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Color _parseColor(String colorString) {
    try {
      // Handle hex color string (e.g., "#FF0000" or "0xFF0000")
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Fallback to a default color
      return Colors.blue;
    }
  }
}
import 'package:flutter/material.dart';
import '../../../../models/strategic_plan_model.dart';

class RiskAssessmentWidget extends StatelessWidget {
  final StrategicPlan plan;

  const RiskAssessmentWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final risks = plan.risks;
    final mitigations = plan.mitigationStrategies;

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
            Text(
              'Risk Assessment & Mitigation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Identified risks and mitigation strategies',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            // Risk Matrix
            _buildRiskMatrix(),

            const SizedBox(height: 32),

            // Risks List
            if (risks.isNotEmpty) ...[
              Text(
                'Identified Risks',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              ...risks.map((risk) => _buildRiskCard(risk)).toList(),
            ] else
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No risks identified',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Mitigation Strategies
            if (mitigations.isNotEmpty) ...[
              Text(
                'Mitigation Strategies',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              ...mitigations
                  .map((mitigation) => _buildMitigationCard(mitigation))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMatrix() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Matrix',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // Matrix Grid
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Grid background
                _buildMatrixGrid(),

                // Risk points
                ..._plotRiskPoints(),

                // Legend
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildRiskLegend(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low Probability',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'High Probability',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Transform.rotate(
              angle: -1.5708, // -90 degrees in radians
              child: Text(
                'Low Impact',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Transform.rotate(
              angle: -1.5708,
              child: Text(
                'High Impact',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: 25,
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;

        Color getCellColor() {
          if (row + col >= 7) return Colors.red.shade100; // High risk
          if (row + col >= 5) return Colors.orange.shade100; // Medium risk
          return Colors.green.shade100; // Low risk
        }

        return Container(
          color: getCellColor(),
          child: Center(
            child: Text(
              '${row + 1}-${col + 1}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _plotRiskPoints() {
    final risks = plan.risks;
    final points = <Widget>[];

    for (final risk in risks) {
      final probability = (risk['probability'] ?? 1).toDouble();
      final impact = (risk['impact'] ?? 1).toDouble();
      final severity = (risk['severity'] ?? 'low').toString();

      // Convert to grid coordinates (1-5 scale)
      final x = (probability.clamp(1, 5) - 1) / 4;
      final y = (impact.clamp(1, 5) - 1) / 4;

      // Convert to position in the 200x200 grid
      final left = x * 200;
      final top = (1 - y) * 200; // Invert y-axis

      points.add(
        Positioned(
          left: left - 8,
          top: top - 8,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getSeverityColor(severity),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                risk['id']?.toString().substring(0, 1) ?? 'R',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return points;
  }

  Widget _buildRiskLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Risk Severity',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('Critical', Colors.red),
          _buildLegendItem('High', Colors.orange),
          _buildLegendItem('Medium', Colors.yellow),
          _buildLegendItem('Low', Colors.green),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(Map<String, dynamic> risk) {
    final probability = (risk['probability'] ?? 1).toDouble();
    final impact = (risk['impact'] ?? 1).toDouble();
    final severity = (risk['severity'] ?? 'low').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: _getSeverityColor(severity).withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning,
                    size: 20,
                    color: _getSeverityColor(severity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        risk['title'] ?? 'Unnamed Risk',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        risk['description'] ?? 'No description',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getSeverityColor(severity),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Risk Metrics
            Row(
              children: [
                _buildRiskMetric('Probability',
                    '${(probability * 20).toStringAsFixed(0)}%', Colors.blue),
                const SizedBox(width: 16),
                _buildRiskMetric('Impact',
                    '${(impact * 20).toStringAsFixed(0)}%', Colors.red),
                const SizedBox(width: 16),
                _buildRiskMetric(
                    'Risk Score',
                    '${(probability * impact).toStringAsFixed(1)}',
                    Colors.orange),
                const Spacer(),
                _buildRiskMetric(
                    'Owner', risk['owner'] ?? 'Unassigned', Colors.green),
              ],
            ),

            if (risk['mitigation'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mitigation: ${risk['mitigation']}',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMitigationCard(Map<String, dynamic> mitigation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.shield, size: 20, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mitigation['strategy'] ?? 'Unnamed Mitigation',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(
                  label: Text(mitigation['status'] ?? 'Planned'),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mitigation['description'] ?? 'No description',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMitigationDetail(
                    'Owner', mitigation['owner'] ?? 'Unassigned'),
                const SizedBox(width: 16),
                _buildMitigationDetail(
                    'Cost', '\$${mitigation['cost'] ?? '0'}'),
                const SizedBox(width: 16),
                _buildMitigationDetail(
                    'Timeline', mitigation['timeline'] ?? 'Not specified'),
                const Spacer(),
                _buildMitigationDetail(
                    'Effectiveness', '${mitigation['effectiveness'] ?? '0'}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMitigationDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

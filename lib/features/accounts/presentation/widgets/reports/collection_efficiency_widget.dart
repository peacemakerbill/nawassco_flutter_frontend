import 'package:flutter/material.dart';

class CollectionEfficiencyWidget extends StatefulWidget {
  final Function(DateTime, DateTime) onGenerateReport;

  const CollectionEfficiencyWidget({super.key, required this.onGenerateReport});

  @override
  State<CollectionEfficiencyWidget> createState() => _CollectionEfficiencyWidgetState();
}

class _CollectionEfficiencyWidgetState extends State<CollectionEfficiencyWidget> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final efficiencyData = {
      'currentRate': '94.2%',
      'targetRate': '95.0%',
      'previousRate': '92.8%',
      'improvement': '+1.4%',
      'totalBilled': 'KES 4.5M',
      'totalCollected': 'KES 4.24M',
      'outstanding': 'KES 260K',
    };

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collection Efficiency Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Date Range Selection
            _buildDateRangeSelector(),
            const SizedBox(height: 20),

            // Efficiency Metrics
            _buildEfficiencyMetrics(efficiencyData),
            const SizedBox(height: 20),

            // Efficiency Chart
            _buildEfficiencyChart(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Start Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(
                text: '${_startDate.day}/${_startDate.month}/${_startDate.year}'
            ),
            onTap: () => _selectStartDate(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'End Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(
                text: '${_endDate.day}/${_endDate.month}/${_endDate.year}'
            ),
            onTap: () => _selectEndDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyMetrics(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collection Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildMetricCard('Current Rate', data['currentRate']!, Icons.trending_up, Colors.green),
              _buildMetricCard('Target Rate', data['targetRate']!, Icons.flag, Colors.blue),
              _buildMetricCard('Previous Rate', data['previousRate']!, Icons.history, Colors.orange),
              _buildMetricCard('Improvement', data['improvement']!, Icons.arrow_upward, Colors.green),
              _buildMetricCard('Total Billed', data['totalBilled']!, Icons.receipt, Colors.purple),
              _buildMetricCard('Total Collected', data['totalCollected']!, Icons.attach_money, Colors.green),
              _buildMetricCard('Outstanding', data['outstanding']!, Icons.money_off, Colors.red),
              _buildProgressIndicator(double.parse(data['currentRate']!.replaceAll('%', ''))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collection Efficiency Trend',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Efficiency Trend Chart'),
                  Text('Monthly collection efficiency visualization',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _viewDetailedAnalysis,
            icon: const Icon(Icons.analytics),
            label: const Text('DETAILED ANALYSIS'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.assessment),
            label: const Text('GENERATE REPORT'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double efficiency) {
    final progress = efficiency / 100;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              '$efficiency%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: progress >= 0.9 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: progress >= 0.9 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 2),
            const Text(
              'Efficiency',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() => _endDate = picked);
    }
  }

  void _viewDetailedAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening detailed analysis...')),
    );
  }

  void _generateReport() {
    widget.onGenerateReport(_startDate, _endDate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection efficiency report generated')),
    );
  }
}
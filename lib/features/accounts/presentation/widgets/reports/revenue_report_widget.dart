import 'package:flutter/material.dart';

class RevenueReportWidget extends StatefulWidget {
  final Function(DateTime, DateTime, String) onGenerateReport;

  const RevenueReportWidget({super.key, required this.onGenerateReport});

  @override
  State<RevenueReportWidget> createState() => _RevenueReportWidgetState();
}

class _RevenueReportWidgetState extends State<RevenueReportWidget> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportType = 'monthly';
  String _format = 'pdf';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Report Generator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Report Configuration
            _buildReportConfiguration(),
            const SizedBox(height: 20),

            // Report Preview
            _buildReportPreview(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Configuration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: _reportType,
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly Revenue')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly Revenue')),
                  DropdownMenuItem(value: 'annual', child: Text('Annual Revenue')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom Period')),
                ],
                onChanged: (value) => setState(() => _reportType = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField(
                value: _format,
                decoration: const InputDecoration(
                  labelText: 'Output Format',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pdf', child: Text('PDF Document')),
                  DropdownMenuItem(value: 'excel', child: Text('Excel Spreadsheet')),
                  DropdownMenuItem(value: 'csv', child: Text('CSV File')),
                ],
                onChanged: (value) => setState(() => _format = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportPreview() {
    final previewData = {
      'totalRevenue': 'KES 4.2M',
      'waterSales': 'KES 2.8M',
      'sewerage': 'KES 850K',
      'connectionFees': 'KES 350K',
      'otherIncome': 'KES 200K',
      'growthRate': '+12.5%',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Preview',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildPreviewItem('Total Revenue', previewData['totalRevenue']!, Icons.attach_money),
              _buildPreviewItem('Water Sales', previewData['waterSales']!, Icons.water_drop),
              _buildPreviewItem('Sewerage', previewData['sewerage']!, Icons.gite),
              _buildPreviewItem('Connection Fees', previewData['connectionFees']!, Icons.build),
              _buildPreviewItem('Other Income', previewData['otherIncome']!, Icons.more_horiz),
              _buildPreviewItem('Growth Rate', previewData['growthRate']!, Icons.trending_up),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Period: 1 Jan 2024 - 31 Jan 2024',
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
            onPressed: _previewReport,
            icon: const Icon(Icons.visibility),
            label: const Text('PREVIEW REPORT'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.download),
            label: const Text('GENERATE REPORT'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
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

  void _previewReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report preview generated')),
    );
  }

  void _generateReport() {
    widget.onGenerateReport(_startDate, _endDate, _format);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Revenue report generated successfully')),
    );
  }
}
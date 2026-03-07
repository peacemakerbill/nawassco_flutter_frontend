import 'package:flutter/material.dart';

class CustomReportBuilder extends StatefulWidget {
  final Function(String, List<String>, Map<String, dynamic>) onBuildReport;

  const CustomReportBuilder({super.key, required this.onBuildReport});

  @override
  State<CustomReportBuilder> createState() => _CustomReportBuilderState();
}

class _CustomReportBuilderState extends State<CustomReportBuilder> {
  final TextEditingController _reportNameController = TextEditingController();
  String _dataSource = 'customers';
  final List<String> _selectedFields = [];
  final Map<String, dynamic> _filters = {};

  final Map<String, List<String>> _availableFields = {
    'customers': [
      'accountNumber',
      'customerName',
      'meterNumber',
      'zone',
      'customerType',
      'connectionDate',
      'accountStatus',
      'currentBalance',
      'lastPaymentDate',
    ],
    'payments': [
      'transactionId',
      'paymentDate',
      'amount',
      'paymentMethod',
      'referenceNumber',
      'processedBy',
      'status',
    ],
    'controller': [
      'invoiceNumber',
      'billingDate',
      'dueDate',
      'amount',
      'balanceDue',
      'consumption',
      'tariffType',
    ],
  };

  final Map<String, List<String>> _availableFilters = {
    'dateRange': ['Last 7 days', 'Last 30 days', 'Last 90 days', 'Custom range'],
    'status': ['Active', 'Overdue', 'Delinquent', 'Inactive'],
    'zone': ['Nakuru East', 'Nakuru West', 'Bahati', 'Molo', 'Naivasha'],
    'customerType': ['Residential', 'Commercial', 'Industrial'],
  };

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
              'Custom Report Builder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Report Configuration
            _buildReportConfiguration(),
            const SizedBox(height: 20),

            // Field Selection
            _buildFieldSelection(),
            const SizedBox(height: 20),

            // Filters
            _buildFiltersSection(),
            const SizedBox(height: 20),

            // Report Preview
            if (_selectedFields.isNotEmpty) _buildReportPreview(),
            if (_selectedFields.isNotEmpty) const SizedBox(height: 20),

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
                controller: _reportNameController,
                decoration: const InputDecoration(
                  labelText: 'Report Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Customer Balance Report',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField(
                value: _dataSource,
                decoration: const InputDecoration(
                  labelText: 'Data Source',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'customers', child: Text('Customer Data')),
                  DropdownMenuItem(value: 'payments', child: Text('Payment Data')),
                  DropdownMenuItem(value: 'controller', child: Text('Billing Data')),
                ],
                onChanged: (value) {
                  setState(() {
                    _dataSource = value!;
                    _selectedFields.clear();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Fields to Include',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Available fields for ${_getDataSourceName()} data:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFields[_dataSource]!.map((field) {
            final isSelected = _selectedFields.contains(field);
            return FilterChip(
              label: Text(_getFieldDisplayName(field)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFields.add(field);
                  } else {
                    _selectedFields.remove(field);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Filters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _availableFilters.entries.map((entry) {
            return SizedBox(
              width: 200,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: _getFilterDisplayName(entry.key),
                  border: const OutlineInputBorder(),
                ),
                items: entry.value.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filters[entry.key] = value;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReportPreview() {
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
          Text(
            'Report: ${_reportNameController.text.isNotEmpty ? _reportNameController.text : "Unnamed Report"}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text('Data Source: ${_getDataSourceName()}'),
          Text('Fields: ${_selectedFields.length} selected'),
          Text('Filters: ${_filters.length} applied'),
          const SizedBox(height: 12),
          const Text(
            'Sample Data:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView(
              children: _selectedFields.take(5).map((field) {
                return Text(
                  '• ${_getFieldDisplayName(field)}: Sample data',
                  style: const TextStyle(fontSize: 12),
                );
              }).toList(),
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
            onPressed: _previewReport,
            icon: const Icon(Icons.visibility),
            label: const Text('PREVIEW REPORT'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _saveTemplate,
            icon: const Icon(Icons.save),
            label: const Text('SAVE TEMPLATE'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedFields.isNotEmpty ? _generateReport : null,
            icon: const Icon(Icons.build),
            label: const Text('BUILD REPORT'),
          ),
        ),
      ],
    );
  }

  String _getDataSourceName() {
    return switch (_dataSource) {
      'customers' => 'Customer',
      'payments' => 'Payment',
      'controller' => 'Billing',
      _ => 'Unknown',
    };
  }

  String _getFieldDisplayName(String field) {
    final displayNames = {
      'accountNumber': 'Account Number',
      'customerName': 'Customer Name',
      'meterNumber': 'Meter Number',
      'zone': 'Zone',
      'customerType': 'Customer Type',
      'connectionDate': 'Connection Date',
      'accountStatus': 'Account Status',
      'currentBalance': 'Current Balance',
      'lastPaymentDate': 'Last Payment Date',
      'transactionId': 'Transaction ID',
      'paymentDate': 'Payment Date',
      'amount': 'Amount',
      'paymentMethod': 'Payment Method',
      'referenceNumber': 'Reference Number',
      'processedBy': 'Processed By',
      'status': 'Status',
      'invoiceNumber': 'Invoice Number',
      'billingDate': 'Billing Date',
      'dueDate': 'Due Date',
      'balanceDue': 'Balance Due',
      'consumption': 'Consumption',
      'tariffType': 'Tariff Type',
    };
    return displayNames[field] ?? field;
  }

  String _getFilterDisplayName(String filter) {
    final displayNames = {
      'dateRange': 'Date Range',
      'status': 'Account Status',
      'zone': 'Zone',
      'customerType': 'Customer Type',
    };
    return displayNames[filter] ?? filter;
  }

  void _previewReport() {
    if (_selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one field')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report preview generated')),
    );
  }

  void _saveTemplate() {
    if (_reportNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a report name')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report template saved')),
    );
  }

  void _generateReport() {
    if (_reportNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a report name')),
      );
      return;
    }

    if (_selectedFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one field')),
      );
      return;
    }

    widget.onBuildReport(_reportNameController.text, _selectedFields, _filters);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Custom report "${_reportNameController.text}" generated')),
    );
  }
}
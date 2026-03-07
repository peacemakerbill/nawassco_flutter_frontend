import 'package:flutter/material.dart';

class BillingRunWidget extends StatefulWidget {
  final Function(DateTime, String) onRunBilling;

  const BillingRunWidget({super.key, required this.onRunBilling});

  @override
  State<BillingRunWidget> createState() => _BillingRunWidgetState();
}

class _BillingRunWidgetState extends State<BillingRunWidget> {
  DateTime _selectedDate = DateTime.now();
  String _selectedGroup = 'all';

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
              'Billing Run Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Billing Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                        text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedGroup,
                    decoration: const InputDecoration(
                      labelText: 'Customer Group',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Customers')),
                      DropdownMenuItem(value: 'residential', child: Text('Residential')),
                      DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                      DropdownMenuItem(value: 'industrial', child: Text('Industrial')),
                    ],
                    onChanged: (value) => setState(() => _selectedGroup = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Billing Summary:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBillingSummary(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _runPreview,
                    child: const Text('PREVIEW BILLING'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runBilling,
                    child: const Text('RUN BILLING'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem('Accounts', '1,245'),
          _SummaryItem('Estimated Revenue', 'KES 2.8M'),
          _SummaryItem('Status', 'Ready'),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _runPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billing preview generated')),
    );
  }

  void _runBilling() {
    widget.onRunBilling(_selectedDate, _selectedGroup);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billing run initiated successfully')),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
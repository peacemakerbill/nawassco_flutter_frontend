import 'package:flutter/material.dart';
import '../../../../../models/job_model.dart';

class SalaryRangeInput extends StatefulWidget {
  final SalaryRange initialRange;
  final ValueChanged<SalaryRange> onChanged;

  const SalaryRangeInput({
    super.key,
    required this.initialRange,
    required this.onChanged,
  });

  @override
  State<SalaryRangeInput> createState() => _SalaryRangeInputState();
}

class _SalaryRangeInputState extends State<SalaryRangeInput> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late String _currency;
  late bool _isNegotiable;
  late PayPeriod _payPeriod;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialRange.min.toString(),
    );
    _maxController = TextEditingController(
      text: widget.initialRange.max.toString(),
    );
    _currency = widget.initialRange.currency;
    _isNegotiable = widget.initialRange.isNegotiable;
    _payPeriod = widget.initialRange.payPeriod;
  }

  void _updateRange() {
    final min = double.tryParse(_minController.text) ?? 0;
    final max = double.tryParse(_maxController.text) ?? 0;

    final range = SalaryRange(
      min: min,
      max: max,
      currency: _currency,
      isNegotiable: _isNegotiable,
      payPeriod: _payPeriod,
    );

    widget.onChanged(range);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Salary',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateRange(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Salary',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateRange(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: ['USD', 'EUR', 'GBP', 'KES', 'INR', 'JPY', 'CNY']
                    .map((currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _currency = value ?? 'USD';
                    _updateRange();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<PayPeriod>(
                value: _payPeriod,
                decoration: const InputDecoration(
                  labelText: 'Pay Period',
                  border: OutlineInputBorder(),
                ),
                items: PayPeriod.values
                    .map((period) => DropdownMenuItem(
                  value: period,
                  child: Text(period.displayName),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _payPeriod = value ?? PayPeriod.MONTHLY;
                    _updateRange();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Salary is negotiable'),
          value: _isNegotiable,
          onChanged: (value) {
            setState(() {
              _isNegotiable = value ?? false;
              _updateRange();
            });
          },
        ),
      ],
    );
  }
}
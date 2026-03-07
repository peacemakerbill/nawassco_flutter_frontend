import 'package:flutter/material.dart';

import '../../../models/tariff_model.dart';

class ServiceChargeWidget extends StatefulWidget {
  final List<ServiceCharge> charges;
  final String title;
  final String description;
  final ValueChanged<List<ServiceCharge>> onChargesUpdated;

  const ServiceChargeWidget({
    super.key,
    required this.charges,
    required this.title,
    required this.description,
    required this.onChargesUpdated,
  });

  @override
  State<ServiceChargeWidget> createState() => _ServiceChargeWidgetState();
}

class _ServiceChargeWidgetState extends State<ServiceChargeWidget> {
  late List<ServiceCharge> _charges;

  @override
  void initState() {
    super.initState();
    _charges = List.from(widget.charges);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _addCharge,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Charge'),
                ),
                const SizedBox(width: 8),
                if (_charges.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _clearAllCharges,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.description,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        if (_charges.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.money_off,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No ${widget.title.toLowerCase()} configured',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add charges to include in billing calculations',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ..._charges.asMap().entries.map((entry) {
            final index = entry.key;
            final charge = entry.value;
            return _buildChargeCard(charge, index);
          }),
      ],
    );
  }

  Widget _buildChargeCard(ServiceCharge charge, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  charge.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(charge.calculationType.displayName),
                      backgroundColor: _getChargeColor(charge.calculationType),
                      labelStyle: TextStyle(
                        color: _getChargeTextColor(charge.calculationType),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _editCharge(index),
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _removeCharge(index),
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChargeDetail(
                    'Amount',
                    charge.calculationType == CalculationType.percentage
                        ? '${charge.amount}%'
                        : 'KES ${charge.amount}',
                  ),
                ),
                Expanded(
                  child: _buildChargeDetail(
                    'Taxable',
                    charge.isTaxable ? 'Yes' : 'No',
                  ),
                ),
              ],
            ),
            if (charge.basis != null && charge.basis!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildChargeDetail('Basis', charge.basis!),
              ),
            if (charge.minAmount != null || charge.maxAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (charge.minAmount != null)
                      Expanded(
                        child: _buildChargeDetail(
                          'Min Amount',
                          'KES ${charge.minAmount}',
                        ),
                      ),
                    if (charge.maxAmount != null)
                      Expanded(
                        child: _buildChargeDetail(
                          'Max Amount',
                          'KES ${charge.maxAmount}',
                        ),
                      ),
                  ],
                ),
              ),
            if (charge.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  charge.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeDetail(String label, String value) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getChargeColor(CalculationType type) {
    switch (type) {
      case CalculationType.fixed:
        return Colors.blue.shade50;
      case CalculationType.percentage:
        return Colors.green.shade50;
      case CalculationType.perUnit:
        return Colors.orange.shade50;
    }
  }

  Color _getChargeTextColor(CalculationType type) {
    switch (type) {
      case CalculationType.fixed:
        return Colors.blue.shade700;
      case CalculationType.percentage:
        return Colors.green.shade700;
      case CalculationType.perUnit:
        return Colors.orange.shade700;
    }
  }

  void _addCharge() async {
    final result = await showDialog<ServiceCharge>(
      context: context,
      builder: (context) => const _ServiceChargeDialog(),
    );

    if (result != null) {
      setState(() {
        _charges.add(result);
        widget.onChargesUpdated(_charges);
      });
    }
  }

  void _editCharge(int index) async {
    final original = _charges[index];
    final result = await showDialog<ServiceCharge>(
      context: context,
      builder: (context) => _ServiceChargeDialog(charge: original),
    );

    if (result != null) {
      setState(() {
        _charges[index] = result;
        widget.onChargesUpdated(_charges);
      });
    }
  }

  void _removeCharge(int index) {
    setState(() {
      _charges.removeAt(index);
      widget.onChargesUpdated(_charges);
    });
  }

  void _clearAllCharges() {
    setState(() {
      _charges.clear();
      widget.onChargesUpdated(_charges);
    });
  }
}

class _ServiceChargeDialog extends StatefulWidget {
  final ServiceCharge? charge;

  const _ServiceChargeDialog({this.charge});

  @override
  _ServiceChargeDialogState createState() => _ServiceChargeDialogState();
}

class _ServiceChargeDialogState extends State<_ServiceChargeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _basisController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  CalculationType _calculationType = CalculationType.fixed;
  bool _isTaxable = true;

  @override
  void initState() {
    super.initState();
    if (widget.charge != null) {
      final charge = widget.charge!;
      _nameController.text = charge.name;
      _amountController.text = charge.amount.toString();
      _basisController.text = charge.basis ?? '';
      _descriptionController.text = charge.description;
      _minAmountController.text = charge.minAmount?.toString() ?? '';
      _maxAmountController.text = charge.maxAmount?.toString() ?? '';
      _calculationType = charge.calculationType;
      _isTaxable = charge.isTaxable;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.charge == null ? 'Add Charge' : 'Edit Charge'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Charge Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        border: const OutlineInputBorder(),
                        prefixText:
                            _calculationType == CalculationType.percentage
                                ? null
                                : 'KES ',
                        suffixText:
                            _calculationType == CalculationType.percentage
                                ? '%'
                                : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount < 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CalculationType>(
                      value: _calculationType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: CalculationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _calculationType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _basisController,
                decoration: const InputDecoration(
                  labelText: 'Basis (Optional)',
                  border: OutlineInputBorder(),
                  helperText: 'What this charge is based on',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Min Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Taxable'),
                subtitle: const Text('Whether this charge is subject to taxes'),
                value: _isTaxable,
                onChanged: (value) => setState(() => _isTaxable = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final charge = ServiceCharge(
                name: _nameController.text,
                amount: double.parse(_amountController.text),
                calculationType: _calculationType,
                basis: _basisController.text.isNotEmpty
                    ? _basisController.text
                    : null,
                minAmount: _minAmountController.text.isNotEmpty
                    ? double.parse(_minAmountController.text)
                    : null,
                maxAmount: _maxAmountController.text.isNotEmpty
                    ? double.parse(_maxAmountController.text)
                    : null,
                isTaxable: _isTaxable,
                description: _descriptionController.text,
              );
              Navigator.pop(context, charge);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

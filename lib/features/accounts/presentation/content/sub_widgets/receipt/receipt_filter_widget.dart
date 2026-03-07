import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/receipt_model.dart';
import '../../../../providers/receipt_provider.dart';

class ReceiptFilterWidget extends ConsumerStatefulWidget {
  const ReceiptFilterWidget({super.key});

  @override
  ConsumerState<ReceiptFilterWidget> createState() =>
      _ReceiptFilterWidgetState();
}

class _ReceiptFilterWidgetState extends ConsumerState<ReceiptFilterWidget> {
  ReceiptType? _selectedReceiptType;
  ReceiptStatus? _selectedStatus;
  PayerType? _selectedPayerType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Receipts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Receipt Type Filter
          DropdownButtonFormField<ReceiptType>(
            value: _selectedReceiptType,
            decoration: const InputDecoration(
              labelText: 'Receipt Type',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ...ReceiptType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 16),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedReceiptType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Status Filter
          DropdownButtonFormField<ReceiptStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...ReceiptStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Icon(status.icon, color: status.color, size: 16),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Payer Type Filter
          DropdownButtonFormField<PayerType>(
            value: _selectedPayerType,
            decoration: const InputDecoration(
              labelText: 'Payer Type',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('All Payer Types')),
              ...PayerType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPayerType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => _selectDate(context, true),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => _selectDate(context, false),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('CLEAR FILTERS'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  child: const Text('APPLY FILTERS'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedReceiptType = null;
      _selectedStatus = null;
      _selectedPayerType = null;
      _startDate = null;
      _endDate = null;
    });
    ref.read(receiptProvider.notifier).setFilters({});
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedReceiptType != null) {
      filters['receiptType'] = _selectedReceiptType!.apiName;
    }

    if (_selectedStatus != null) {
      filters['status'] = _selectedStatus!.apiName;
    }

    if (_selectedPayerType != null) {
      filters['payerType'] = _selectedPayerType!.apiName;
    }

    if (_startDate != null) {
      filters['startDate'] = _startDate!.toIso8601String();
    }

    if (_endDate != null) {
      filters['endDate'] = _endDate!.toIso8601String();
    }

    ref.read(receiptProvider.notifier).setFilters(filters);
    Navigator.of(context).pop();
  }
}
import 'package:flutter/material.dart';

import '../../../../models/field_inventory.dart';

class UsageRecordDialog extends StatefulWidget {
  final FieldInventory item;
  final Function(int quantity, String workOrderId) onRecord;

  const UsageRecordDialog({
    super.key,
    required this.item,
    required this.onRecord,
  });

  @override
  State<UsageRecordDialog> createState() => _UsageRecordDialogState();
}

class _UsageRecordDialogState extends State<UsageRecordDialog> {
  final _quantityController = TextEditingController();
  final _workOrderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    _workOrderController.dispose();
    super.dispose();
  }

  void _recordUsage() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      if (quantity > 0) {
        widget.onRecord(
          quantity,
          _workOrderController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Inventory Usage'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${widget.item.itemName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Available: ${widget.item.currentStock} ${widget.item.unit}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity Used (${widget.item.unit})',
                border: const OutlineInputBorder(),
                suffixText: widget.item.unit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity';
                }
                if (quantity > widget.item.currentStock) {
                  return 'Cannot use more than available stock';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workOrderController,
              decoration: const InputDecoration(
                labelText: 'Work Order ID (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.item.currentStock <= widget.item.reorderPoint)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stock will fall below reorder point after this usage',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _recordUsage,
          child: const Text('Record Usage'),
        ),
      ],
    );
  }
}
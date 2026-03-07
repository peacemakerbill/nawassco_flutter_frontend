import 'package:flutter/material.dart';
import '../../../../models/field_inventory.dart';

class StockManagementDialog extends StatefulWidget {
  final FieldInventory item;
  final Function(int quantity, StockAction action) onUpdate;

  const StockManagementDialog({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<StockManagementDialog> createState() => _StockManagementDialogState();
}

class _StockManagementDialogState extends State<StockManagementDialog> {
  final _quantityController = TextEditingController();
  StockAction _selectedAction = StockAction.add;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateStock() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      if (quantity > 0) {
        widget.onUpdate(quantity, _selectedAction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Stock Level'),
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
              'Current Stock: ${widget.item.currentStock} ${widget.item.unit}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<StockAction>(
              value: _selectedAction,
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
              ),
              items: StockAction.values.map((action) {
                return DropdownMenuItem(
                  value: action,
                  child: Text(
                    action.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAction = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${widget.item.unit})',
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
                if (_selectedAction == StockAction.remove &&
                    quantity > widget.item.currentStock) {
                  return 'Cannot remove more than current stock';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            if (_selectedAction == StockAction.remove &&
                widget.item.currentStock <= widget.item.reorderPoint)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stock is below reorder point (${widget.item.reorderPoint} ${widget.item.unit})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
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
          onPressed: _updateStock,
          child: const Text('Update Stock'),
        ),
      ],
    );
  }
}
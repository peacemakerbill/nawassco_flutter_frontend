import 'package:flutter/material.dart';

import '../../../../models/quote.model.dart';

class QuoteItemWidget extends StatefulWidget {
  final QuoteItem item;
  final int index;
  final Function(QuoteItem) onUpdate;
  final Function() onRemove;

  const QuoteItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<QuoteItemWidget> createState() => _QuoteItemWidgetState();
}

class _QuoteItemWidgetState extends State<QuoteItemWidget> {
  late TextEditingController _itemCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _unitPriceController;
  late TextEditingController _taxRateController;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _itemCodeController = TextEditingController(text: widget.item.itemCode);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _unitController = TextEditingController(text: widget.item.unit);
    _unitPriceController =
        TextEditingController(text: widget.item.unitPrice.toStringAsFixed(2));
    _taxRateController =
        TextEditingController(text: widget.item.taxRate.toStringAsFixed(1));
    _discountController =
        TextEditingController(text: widget.item.discount.toStringAsFixed(2));

    _itemCodeController.addListener(_updateItem);
    _descriptionController.addListener(_updateItem);
    _quantityController.addListener(_updateItem);
    _unitController.addListener(_updateItem);
    _unitPriceController.addListener(_updateItem);
    _taxRateController.addListener(_updateItem);
    _discountController.addListener(_updateItem);
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateItem() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 16;
    final discount = double.tryParse(_discountController.text) ?? 0;

    final updatedItem = QuoteItem.create(
      id: widget.item.id,
      itemCode: _itemCodeController.text,
      description: _descriptionController.text,
      quantity: quantity,
      unit: _unitController.text,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discount: discount,
    );

    widget.onUpdate(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.item.quantity * widget.item.unitPrice;
    final netPrice = totalPrice - widget.item.discount;
    final totalWithTax = netPrice + widget.item.taxAmount;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Item Code & Description
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _itemCodeController,
                    decoration: InputDecoration(
                      labelText: 'Item Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quantity, Unit, Price
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: InputDecoration(
                      labelText: 'Unit Price (KES)',
                      prefixText: 'KES ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tax & Discount
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    decoration: InputDecoration(
                      labelText: 'Tax Rate (%)',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Discount (KES)',
                      prefixText: 'KES ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'KES ${widget.item.totalWithTax.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal: KES ${widget.item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Tax: KES ${widget.item.taxAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Discount: KES ${widget.item.discount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
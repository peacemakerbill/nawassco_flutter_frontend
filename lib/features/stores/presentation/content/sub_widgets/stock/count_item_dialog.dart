import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/stock/stock_take_model.dart';
import '../../../../providers/inventory_item_provider.dart';
import '../../../../providers/stock_take_provider.dart';

class CountItemDialog extends ConsumerStatefulWidget {
  final String stockTakeId;
  final VoidCallback? onItemCounted;

  const CountItemDialog({
    super.key,
    required this.stockTakeId,
    this.onItemCounted,
  });

  @override
  ConsumerState<CountItemDialog> createState() => _CountItemDialogState();
}

class _CountItemDialogState extends ConsumerState<CountItemDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedItemId;
  double _countedQuantity = 0;
  double _expectedQuantity = 0;
  String? _batchNumber;
  String _condition = 'good';
  String _remarks = '';

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryItemProvider);
    final stockTakeState = ref.watch(stockTakeProvider);
    final stockTake = stockTakeState.stockTakes.firstWhere(
          (st) => st.id == widget.stockTakeId,
      orElse: () => StockTake(
        id: '',
        stockTakeNumber: '',
        stockTakeType: 'cycle_count',
        stockTakeDate: DateTime.now(),
        warehouse: '',
        zones: [],
        countedItems: [],
        totalItems: 0,
        countedItemsCount: 0,
        varianceItems: 0,
        totalExpectedValue: 0,
        totalCountedValue: 0,
        totalVarianceValue: 0,
        variancePercentage: 0,
        status: 'planned',
        countingStatus: 'not_started',
        approvalStatus: 'pending',
        countingTeam: [],
        supervisor: '',
        adjustments: [],
        adjustmentRequired: false,
        documents: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Count Inventory Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStockTakeInfo(stockTake),
                      const SizedBox(height: 24),
                      _buildItemSelection(inventoryState),
                      const SizedBox(height: 16),
                      _buildQuantitySection(),
                      const SizedBox(height: 16),
                      _buildAdditionalDetails(),
                    ],
                  ),
                ),
              ),

              // Footer actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                        ),
                        child: const Text('Record Count'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ——————————————————————————————————————————
  // STOCK TAKE INFO CARD
  // ——————————————————————————————————————————
  Widget _buildStockTakeInfo(StockTake stockTake) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Take Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoDisplay(label: 'Stock Take', value: stockTake.stockTakeNumber),
                const SizedBox(width: 24),
                _InfoDisplay(label: 'Warehouse', value: stockTake.warehouse),
                const SizedBox(width: 24),
                _InfoDisplay(
                  label: 'Progress',
                  value: '${stockTake.countedItemsCount}/${stockTake.totalItems}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ——————————————————————————————————————————
  // ITEM SELECTION DROPDOWN
  // ——————————————————————————————————————————
  Widget _buildItemSelection(InventoryItemState inventoryState) {
    final stockTakeState = ref.read(stockTakeProvider);
    final stockTake = stockTakeState.stockTakes.firstWhere(
          (st) => st.id == widget.stockTakeId,
      orElse: () => stockTakeState.stockTakes.first,
    );

    final availableItems = inventoryState.items.where((item) {
      return !stockTake.countedItems.any((e) => e.itemId == item.id);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Selection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedItemId,
              decoration: const InputDecoration(
                labelText: 'Select Item',
                border: OutlineInputBorder(),
                hintText: 'Choose an item to count',
              ),
              items: availableItems.map((item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.itemCode} - ${item.itemName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Current Stock: ${item.currentStock}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItemId = value;

                  if (value != null) {
                    final item = inventoryState.items.firstWhere(
                          (i) => i.id == value,
                      orElse: () => inventoryState.items.first,
                    );

                    _expectedQuantity = item.currentStock.toDouble();
                    _countedQuantity = item.currentStock.toDouble();
                  }
                });
              },
              validator: (value) =>
              value == null || value.isEmpty ? 'Please select an item' : null,
            ),
          ],
        ),
      ),
    );
  }

  // ——————————————————————————————————————————
  // QUANTITY SECTION
  // ——————————————————————————————————————————
  Widget _buildQuantitySection() {
    final variance = _countedQuantity - _expectedQuantity;
    final variancePercent =
    _expectedQuantity > 0 ? (variance / _expectedQuantity * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _expectedQuantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Expected Quantity',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _countedQuantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Counted Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _countedQuantity = double.tryParse(value) ?? 0.0;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a quantity';
                      }
                      final qty = double.tryParse(value);
                      if (qty == null || qty < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// VARIANCE BADGE
            if (_selectedItemId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getVarianceColor(variancePercent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${variance >= 0 ? '+' : ''}${variance.toStringAsFixed(2)} units',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      '${variancePercent >= 0 ? '+' : ''}${variancePercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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

  // ——————————————————————————————————————————
  // ADDITIONAL DETAILS
  // ——————————————————————————————————————————
  Widget _buildAdditionalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Batch Number (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter batch number if applicable',
              ),
              onChanged: (value) => _batchNumber = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'Item Condition',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'good', child: Text('Good')),
                DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                DropdownMenuItem(value: 'expired', child: Text('Expired')),
                DropdownMenuItem(value: 'defective', child: Text('Defective')),
                DropdownMenuItem(value: 'returned', child: Text('Returned')),
                DropdownMenuItem(value: 'quarantined', child: Text('Quarantined')),
              ],
              onChanged: (value) => setState(() => _condition = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Any additional notes about this count...',
              ),
              onChanged: (value) => _remarks = value,
            ),
          ],
        ),
      ),
    );
  }

  // ——————————————————————————————————————————
  // VARIANCE COLOR LOGIC  (FIXED)
  // ——————————————————————————————————————————
  Color _getVarianceColor(num variancePercent) {
    final double v = variancePercent.toDouble().abs();

    if (v <= 1) {
      return Colors.green.withOpacity(0.2);
    } else if (v <= 5) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.red.withOpacity(0.2);
    }
  }

  // ——————————————————————————————————————————
  // SUBMIT LOGIC
  // ——————————————————————————————————————————
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedItemId != null) {
      final countedItemData = {
        'item': _selectedItemId!,
        'countedQuantity': _countedQuantity,
        'batchNumber': _batchNumber,
        'condition': _condition,
        'remarks': _remarks,
      };

      final authState = ref.read(authProvider);
      await ref.read(stockTakeProvider.notifier).addCountedItem(
        widget.stockTakeId,
        countedItemData,
        authState.user?['_id'] ?? '',
      );

      if (!mounted) return;

      Navigator.pop(context);
      widget.onItemCounted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item counted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ——————————————————————————————————————————
// INFO DISPLAY SMALL WIDGET
// ——————————————————————————————————————————
class _InfoDisplay extends StatelessWidget {
  final String label;
  final String value;

  const _InfoDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
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
}

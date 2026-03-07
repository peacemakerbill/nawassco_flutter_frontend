import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/inventory_item_provider.dart';

class StockTakeTab extends ConsumerStatefulWidget {
  const StockTakeTab({super.key});

  @override
  ConsumerState<StockTakeTab> createState() => _StockTakeTabState();
}

class _StockTakeTabState extends ConsumerState<StockTakeTab> {
  final Map<String, double> _countedItems = {};
  bool _isCounting = false;

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryItemProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.checklist, color: Color(0xFF1E3A8A), size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Stock Counting',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Perform physical stock count and reconcile with system records',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isCounting = !_isCounting;
                              if (!_isCounting) {
                                _countedItems.clear();
                              }
                            });
                          },
                          icon: Icon(_isCounting ? Icons.stop : Icons.play_arrow),
                          label: Text(_isCounting ? 'Stop Counting' : 'Start Stock Take'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCounting ? Colors.orange : const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_isCounting) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _countedItems.isNotEmpty ? _submitCount : null,
                          icon: const Icon(Icons.save),
                          label: const Text('Submit Count'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress Indicator
          if (_isCounting) ...[
            _buildProgressIndicator(inventoryState.items.length),
            const SizedBox(height: 20),
          ],

          // Items List
          if (_isCounting)
            Expanded(
              child: _buildCountingList(inventoryState.items),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ready for Stock Count',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start stock counting to begin physical inventory verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalItems) {
    final counted = _countedItems.length;
    final percentage = totalItems > 0 ? (counted / totalItems) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Counting Progress',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$counted/$totalItems items',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 100 ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}% Complete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: percentage == 100 ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountingList(List<dynamic> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final countedQuantity = _countedItems[item.id] ?? item.currentStock;
        final difference = countedQuantity - item.currentStock;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Item Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            item.itemCode,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            'System: ${item.currentStock} ${item.unitOfMeasure}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Count Input
                    SizedBox(
                      width: 120,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Counted',
                          suffixText: item.unitOfMeasure,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final counted = double.tryParse(value) ?? item.currentStock;
                          setState(() {
                            _countedItems[item.id] = counted;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Difference Indicator
                if (_countedItems.containsKey(item.id))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifferenceColor(difference),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDifferenceIcon(difference),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Difference: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDifferenceColor(double difference) {
    if (difference == 0) return Colors.green;
    if (difference.abs() <= 5) return Colors.orange;
    return Colors.red;
  }

  IconData _getDifferenceIcon(double difference) {
    if (difference == 0) return Icons.check;
    if (difference > 0) return Icons.arrow_upward;
    return Icons.arrow_downward;
  }

  void _submitCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Stock Count'),
        content: Text(
          'Are you sure you want to submit the stock count for ${_countedItems.length} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processStockCount();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _processStockCount() {
    // Here you would typically send the counted items to the backend
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stock count submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _isCounting = false;
      _countedItems.clear();
    });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../providers/inventory_item_provider.dart';
import '../../../../providers/stock_movement_provider.dart';

class CreateMovementDialog extends ConsumerStatefulWidget {
  final VoidCallback? onMovementCreated;

  const CreateMovementDialog({super.key, this.onMovementCreated});

  @override
  ConsumerState<CreateMovementDialog> createState() => _CreateMovementDialogState();
}

class _CreateMovementDialogState extends ConsumerState<CreateMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _items = <MovementItemForm>[];

  String _movementType = 'receipt';
  String _referenceType = 'purchase_order';
  String _status = 'draft';
  DateTime _movementDate = DateTime.now();
  String _referenceNumber = '';
  String _notes = '';

  // Location fields
  String _fromType = 'warehouse';
  String _fromWarehouse = '';
  String _fromZone = '';
  String _fromBinLocation = '';

  String _toType = 'warehouse';
  String _toWarehouse = '';
  String _toZone = '';
  String _toBinLocation = '';

  @override
  void initState() {
    super.initState();
    _generateReferenceNumber();
  }

  void _generateReferenceNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond % 1000;
    setState(() {
      _referenceNumber = 'REF-$timestamp-$random';
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryItemProvider);
    final authState = ref.watch(authProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
          // Header
          Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.move_to_inbox, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                'Create Stock Movement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
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
                // Basic Information
                _buildBasicInfoSection(),
                const SizedBox(height: 24),

                // Locations
                _buildLocationsSection(),
                const SizedBox(height: 24),

                // Items
                _buildItemsSection(inventoryState),
                const SizedBox(height: 24),

                // Notes
                _buildNotesSection(),
              ],
            ),
          ),
        ),

        // Actions
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
                child: const Text('Create Movement'),
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

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _movementType,
                decoration: const InputDecoration(
                  labelText: 'Movement Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'receipt', child: Text('Receipt')),
                  DropdownMenuItem(value: 'issue', child: Text('Issue')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                  DropdownMenuItem(value: 'return', child: Text('Return')),
                  DropdownMenuItem(value: 'adjustment', child: Text('Adjustment')),
                  DropdownMenuItem(value: 'write_off', child: Text('Write Off')),
                ],
                onChanged: (value) {
                  setState(() {
                    _movementType = value!;
                    _updateLocationsBasedOnType();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _referenceType,
                decoration: const InputDecoration(
                  labelText: 'Reference Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'purchase_order', child: Text('Purchase Order')),
                  DropdownMenuItem(value: 'sales_order', child: Text('Sales Order')),
                  DropdownMenuItem(value: 'work_order', child: Text('Work Order')),
                  DropdownMenuItem(value: 'transfer_order', child: Text('Transfer Order')),
                  DropdownMenuItem(value: 'adjustment', child: Text('Adjustment')),
                  DropdownMenuItem(value: 'physical_count', child: Text('Physical Count')),
                ],
                onChanged: (value) {
                  setState(() {
                    _referenceType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _referenceNumber,
                decoration: const InputDecoration(
                  labelText: 'Reference Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _referenceNumber = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDatePickerFormField(
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: _movementDate,
                fieldLabelText: 'Movement Date',
                onDateSubmitted: (date) {
                  setState(() {
                    _movementDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Locations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From Location',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _fromType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'warehouse', child: Text('Warehouse')),
                      DropdownMenuItem(value: 'department', child: Text('Department')),
                      DropdownMenuItem(value: 'project', child: Text('Project')),
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _fromType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _fromWarehouse = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To Location',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _toType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'warehouse', child: Text('Warehouse')),
                      DropdownMenuItem(value: 'department', child: Text('Department')),
                      DropdownMenuItem(value: 'project', child: Text('Project')),
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _toType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _toWarehouse = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsSection(InventoryItemState inventoryState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_items.isEmpty)
          const Center(
            child: Column(
              children: [
                Icon(Icons.inventory, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No items added',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _ItemRow(
            item: item,
            inventoryItems: inventoryState.items,
            onRemove: () => _removeItem(index),
            onUpdate: (updatedItem) {
              setState(() {
                _items[index] = updatedItem;
              });
            },
          );
        }),
        if (_items.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_getTotalQuantity()} items • KES ${_getTotalValue().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
      ],
    );
  }

  void _addItem() {
    setState(() {
      _items.add(MovementItemForm());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  int _getTotalQuantity() {
    return _items.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  double _getTotalValue() {
    return _items.fold(0.0, (sum, item) => sum + (item.totalCost ?? 0));
  }

  void _updateLocationsBasedOnType() {
    switch (_movementType) {
      case 'receipt':
        setState(() {
          _fromType = 'supplier';
          _toType = 'warehouse';
        });
        break;
      case 'issue':
        setState(() {
          _fromType = 'warehouse';
          _toType = 'department';
        });
        break;
      case 'transfer':
        setState(() {
          _fromType = 'warehouse';
          _toType = 'warehouse';
        });
        break;
      case 'return':
        setState(() {
          _fromType = 'customer';
          _toType = 'warehouse';
        });
        break;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final movementData = {
        'movementType': _movementType,
        'movementDate': _movementDate.toIso8601String(),
        'referenceNumber': _referenceNumber,
        'referenceType': _referenceType,
        'items': _items.map((item) => item.toJson()).toList(),
        'fromLocation': {
          'type': _fromType,
          'warehouse': _fromWarehouse,
          'zone': _fromZone,
          'binLocation': _fromBinLocation,
        },
        'toLocation': {
          'type': _toType,
          'warehouse': _toWarehouse,
          'zone': _toZone,
          'binLocation': _toBinLocation,
        },
        'notes': _notes,
        'status': _status,
      };

      final authState = ref.read(authProvider);
      await ref.read(stockMovementProvider.notifier).createStockMovement(
        movementData,
        authState.user?['_id'] ?? '',
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onMovementCreated?.call();
      }
    }
  }
}

class MovementItemForm {
  String? itemId;
  int? quantity;
  double? unitCost;
  double? totalCost;
  String? batchNumber;
  String condition = 'good';

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'batchNumber': batchNumber,
      'condition': condition,
    };
  }
}

class _ItemRow extends StatefulWidget {
  final MovementItemForm item;
  final List<dynamic> inventoryItems;
  final VoidCallback onRemove;
  final ValueChanged<MovementItemForm> onUpdate;

  const _ItemRow({
    required this.item,
    required this.inventoryItems,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Selection
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: widget.item.itemId != null &&
                    widget.inventoryItems.any((i) => i.id == widget.item.itemId)
                    ? widget.item.itemId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: (widget.inventoryItems ?? []).map((item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: Text('${item.itemCode ?? ''} - ${item.itemName ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    widget.item.itemId = value;
                    _updateTotalCost();
                  });
                  widget.onUpdate(widget.item);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Quantity
            Expanded(
              child: TextFormField(
                initialValue: widget.item.quantity?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final qty = int.tryParse(value) ?? 0;
                  setState(() {
                    widget.item.quantity = qty;
                    _updateTotalCost();
                  });
                  widget.onUpdate(widget.item);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Unit Cost
            Expanded(
              child: TextFormField(
                initialValue: widget.item.unitCost?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Unit Cost',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final cost = double.tryParse(value) ?? 0.0;
                  setState(() {
                    widget.item.unitCost = cost;
                    _updateTotalCost();
                  });
                  widget.onUpdate(widget.item);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Total Cost
            Expanded(
              child: TextFormField(
                initialValue: widget.item.totalCost?.toStringAsFixed(2) ?? '0.00',
                decoration: const InputDecoration(
                  labelText: 'Total Cost',
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 8),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ],
        ),
      ),
    );
  }

  void _updateTotalCost() {
    final quantity = widget.item.quantity ?? 0;
    final unitCost = widget.item.unitCost ?? 0.0;
    widget.item.totalCost = quantity * unitCost;
  }
}

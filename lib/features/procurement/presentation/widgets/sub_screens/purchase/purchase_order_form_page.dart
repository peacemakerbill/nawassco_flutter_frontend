import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/purchase_order.dart';
import '../../../../providers/purchase_provider.dart';

class PurchaseOrderFormPage extends ConsumerStatefulWidget {
  final PurchaseOrder? existingPO;

  const PurchaseOrderFormPage({super.key, this.existingPO});

  @override
  ConsumerState<PurchaseOrderFormPage> createState() => _PurchaseOrderFormPageState();
}

class _PurchaseOrderFormPageState extends ConsumerState<PurchaseOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _supplierContactController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _deliveryTermsController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _shippingMethodController = TextEditingController();

  DateTime _orderDate = DateTime.now();
  DateTime _expectedDeliveryDate = DateTime.now().add(const Duration(days: 30));
  List<POItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingPO != null) {
      _initializeForm(widget.existingPO!);
    }
  }

  void _initializeForm(PurchaseOrder po) {
    _supplierController.text = po.supplierId;
    _supplierContactController.text = po.supplierContactId;
    _paymentTermsController.text = po.paymentTerms;
    _deliveryTermsController.text = po.deliveryTerms;
    _deliveryAddressController.text = po.deliveryAddress;
    _shippingMethodController.text = po.shippingMethod;
    _orderDate = po.orderDate;
    _expectedDeliveryDate = po.expectedDeliveryDate;
    _items = List.from(po.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPO == null ? 'Create Purchase Order' : 'Edit Purchase Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePurchaseOrder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildItemsSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter supplier ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _supplierContactController,
              decoration: const InputDecoration(
                labelText: 'Supplier Contact ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter supplier contact ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Date'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_orderDate)),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expected Delivery'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_expectedDeliveryDate)),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paymentTermsController,
              decoration: const InputDecoration(
                labelText: 'Payment Terms',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment terms';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _deliveryTermsController,
              decoration: const InputDecoration(
                labelText: 'Delivery Terms',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery terms';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _deliveryAddressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shippingMethodController,
              decoration: const InputDecoration(
                labelText: 'Shipping Method',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter shipping method';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNewItem,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              const Center(
                child: Text('No items added'),
              )
            else
              ..._items.asMap().entries.map((entry) => _buildItemCard(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, POItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            Text('Code: ${item.itemCode}'),
            Text('Description: ${item.description}'),
            Text('Quantity: ${item.quantity} ${item.unit}'),
            Text('Unit Price: KES ${item.unitPrice.toStringAsFixed(2)}'),
            Text('Total: KES ${item.totalPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            onPressed: _savePurchaseOrder,
            child: const Text('Save Purchase Order'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isOrderDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isOrderDate ? _orderDate : _expectedDeliveryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isOrderDate) {
          _orderDate = picked;
        } else {
          _expectedDeliveryDate = picked;
        }
      });
    }
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _savePurchaseOrder() async {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      try {
        final purchaseOrder = PurchaseOrder(
          id: widget.existingPO?.id ?? '',
          poNumber: widget.existingPO?.poNumber ?? '',
          supplierId: _supplierController.text,
          supplierName: '', // Will be populated by backend
          supplierContactId: _supplierContactController.text,
          items: _items,
          subtotal: _items.fold(0, (sum, item) => sum + item.totalPrice),
          taxAmount: 0,
          totalAmount: _items.fold(0, (sum, item) => sum + item.totalPrice),
          currency: 'KES',
          paymentTerms: _paymentTermsController.text,
          deliveryTerms: _deliveryTermsController.text,
          deliveryAddress: _deliveryAddressController.text,
          shippingMethod: _shippingMethodController.text,
          orderDate: _orderDate,
          expectedDeliveryDate: _expectedDeliveryDate,
          status: widget.existingPO?.status ?? 'draft',
          approvalStatus: widget.existingPO?.approvalStatus ?? 'pending',
          invoices: [],
          createdById: '', // Will be set by backend
          createdByName: '',
          createdAt: widget.existingPO?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.existingPO == null) {
          await ref.read(purchaseOrderProvider.notifier).createPurchaseOrder(purchaseOrder);
        } else {
          await ref.read(purchaseOrderDetailProvider(widget.existingPO!.id).notifier).updatePurchaseOrder(purchaseOrder);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase order saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save purchase order: $e')),
          );
        }
      }
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(POItem) onSave;

  const AddItemDialog({super.key, required this.onSave});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemCodeController,
                decoration: const InputDecoration(
                  labelText: 'Item Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price (KES)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
          onPressed: _saveItem,
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = POItem(
        itemCode: _itemCodeController.text,
        description: _descriptionController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        unitPrice: double.parse(_unitPriceController.text),
        totalPrice: double.parse(_quantityController.text) * double.parse(_unitPriceController.text),
      );
      widget.onSave(item);
      Navigator.pop(context);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/invoice.dart';
import '../../../../providers/invoice_provider.dart';


class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _purchaseOrderController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _taxAmountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  DateTime? _invoiceDate;
  DateTime? _dueDate;
  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _populateForm(widget.invoice!);
    } else {
      _currencyController.text = 'KES';
    }
  }

  void _populateForm(Invoice invoice) {
    _invoiceNumberController.text = invoice.invoiceNumber;
    _supplierController.text = invoice.supplierId;
    _purchaseOrderController.text = invoice.purchaseOrderId;
    _totalAmountController.text = invoice.totalAmount.toString();
    _taxAmountController.text = invoice.taxAmount.toString();
    _currencyController.text = invoice.currency;
    _invoiceDate = invoice.invoiceDate;
    _dueDate = invoice.dueDate;
    _items = List.from(invoice.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'Create Invoice' : 'Edit Invoice'),
        actions: [
          if (widget.invoice != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteInvoice,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: 20),

              // Items Section
              _buildItemsSection(),
              const SizedBox(height: 20),

              // Summary Section
              _buildSummarySection(),
              const SizedBox(height: 20),

              // Action Buttons
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter invoice number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
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
              controller: _purchaseOrderController,
              decoration: const InputDecoration(
                labelText: 'Purchase Order ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter purchase order ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Invoice Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _invoiceDate != null
                                ? '${_invoiceDate!.day}/${_invoiceDate!.month}/${_invoiceDate!.year}'
                                : 'Select date',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dueDate != null
                                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                : 'Select date',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Items',
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
                child: Text('No items added', style: TextStyle(color: Colors.grey)),
              )
            else
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemRow(index, item);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text('Qty: ${item.quantity}'),
                ),
                Expanded(
                  child: Text('KES ${item.unitPrice}'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('GL: ${item.glAccount}'),
                ),
                Expanded(
                  child: Text('Center: ${item.costCenter}'),
                ),
                Expanded(
                  child: Text(
                    'Total: KES ${item.totalPrice}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalAmount = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final taxAmount = double.tryParse(_taxAmountController.text) ?? 0.0;
    final grandTotal = totalAmount + taxAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('KES ${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax Amount:'),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _taxAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'KES ${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveAsDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save as Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Submit Invoice'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onAdd: (item) {
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

  void _saveAsDraft() {
    if (_validateForm()) {
      _saveInvoice(InvoiceStatus.draft);
    }
  }

  void _submitForm() {
    if (_validateForm()) {
      _saveInvoice(InvoiceStatus.submitted);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_invoiceDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select invoice date')),
      );
      return false;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select due date')),
      );
      return false;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveInvoice(InvoiceStatus status) async {
    final invoiceData = {
      'invoiceNumber': _invoiceNumberController.text,
      'supplier': _supplierController.text,
      'purchaseOrder': _purchaseOrderController.text,
      'invoiceDate': _invoiceDate!.toIso8601String(),
      'dueDate': _dueDate!.toIso8601String(),
      'totalAmount': double.parse(_totalAmountController.text),
      'taxAmount': double.tryParse(_taxAmountController.text) ?? 0.0,
      'currency': _currencyController.text,
      'items': _items.map((item) => item.toJson()).toList(),
      'status': status.name,
    };

    final success = widget.invoice == null
        ? await ref.read(invoiceProvider.notifier).createInvoice(invoiceData)
        : await ref.read(invoiceProvider.notifier).updateInvoice(
      widget.invoice!.id,
      invoiceData,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.invoice != null) {
      final success = await ref.read(invoiceProvider.notifier).deleteInvoice(widget.invoice!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _supplierController.dispose();
    _purchaseOrderController.dispose();
    _totalAmountController.dispose();
    _taxAmountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(InvoiceItem) onAdd;

  const AddItemDialog({super.key, required this.onAdd});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _glAccountController = TextEditingController();
  final _costCenterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _glAccountController,
              decoration: const InputDecoration(
                labelText: 'GL Account',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCenterController,
              decoration: const InputDecoration(
                labelText: 'Cost Center',
                border: OutlineInputBorder(),
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
          onPressed: _addItem,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addItem() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    final totalPrice = quantity * unitPrice;

    final item = InvoiceItem(
      description: _descriptionController.text,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      glAccount: _glAccountController.text,
      costCenter: _costCenterController.text,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _glAccountController.dispose();
    _costCenterController.dispose();
    super.dispose();
  }
}
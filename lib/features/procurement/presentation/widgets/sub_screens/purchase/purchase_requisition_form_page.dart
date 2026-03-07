import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/purchase_requisition.dart';
import '../../../../providers/purchase_provider.dart';

class PurchaseRequisitionFormPage extends ConsumerStatefulWidget {
  final PurchaseRequisition? existingRequisition;

  const PurchaseRequisitionFormPage({super.key, this.existingRequisition});

  @override
  ConsumerState<PurchaseRequisitionFormPage> createState() => _PurchaseRequisitionFormPageState();
}

class _PurchaseRequisitionFormPageState extends ConsumerState<PurchaseRequisitionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _costCenterController = TextEditingController();
  final TextEditingController _budgetCodeController = TextEditingController();
  final TextEditingController _justificationController = TextEditingController();
  final TextEditingController _expectedOutcomesController = TextEditingController();
  final TextEditingController _alternativeConsideredController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  DateTime _requiredDate = DateTime.now().add(const Duration(days: 30));
  String _urgency = 'medium';
  String _procurementType = 'direct_purchase';
  List<RequisitionItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingRequisition != null) {
      _initializeForm(widget.existingRequisition!);
    }
  }

  void _initializeForm(PurchaseRequisition req) {
    _titleController.text = req.title;
    _descriptionController.text = req.description;
    _departmentController.text = req.department;
    _costCenterController.text = req.costCenter;
    _budgetCodeController.text = req.budgetCode;
    _justificationController.text = req.justification;
    _expectedOutcomesController.text = req.expectedOutcomes;
    _alternativeConsideredController.text = req.alternativeConsidered;
    _categoryController.text = req.category;
    _requiredDate = req.requiredDate;
    _urgency = req.urgency;
    _procurementType = req.procurementType;
    _items = List.from(req.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRequisition == null ? 'Create Purchase Requisition' : 'Edit Purchase Requisition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRequisition,
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
              _buildDetailsSection(),
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
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
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
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter department';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costCenterController,
                    decoration: const InputDecoration(
                      labelText: 'Cost Center',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter cost center';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Required Date'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_requiredDate)),
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
                      const Text('Urgency'),
                      DropdownButtonFormField<String>(
                        value: _urgency,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'high', child: Text('High')),
                          DropdownMenuItem(value: 'critical', child: Text('Critical')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _urgency = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Procurement Type'),
                DropdownButtonFormField<String>(
                  value: _procurementType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'direct_purchase', child: Text('Direct Purchase')),
                    DropdownMenuItem(value: 'tender', child: Text('Tender')),
                    DropdownMenuItem(value: 'quotation', child: Text('Quotation')),
                    DropdownMenuItem(value: 'framework', child: Text('Framework Agreement')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _procurementType = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budgetCodeController,
              decoration: const InputDecoration(
                labelText: 'Budget Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter budget code';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _justificationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Justification',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter justification';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedOutcomesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Expected Outcomes',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expected outcomes';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _alternativeConsideredController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alternative Considered',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter alternatives considered';
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

  Widget _buildItemCard(int index, RequisitionItem item) {
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
            Text('Specifications: ${item.specifications}'),
            Text('Delivery: ${_formatDate(item.deliveryDate)}'),
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
            onPressed: _saveRequisition,
            child: const Text('Save Requisition'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _requiredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _requiredDate = picked;
      });
    }
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) => AddRequisitionItemDialog(
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

  void _saveRequisition() async {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      try {
        final requisition = PurchaseRequisition(
          id: widget.existingRequisition?.id ?? '',
          requisitionNumber: widget.existingRequisition?.requisitionNumber ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          department: _departmentController.text,
          costCenter: _costCenterController.text,
          budgetCode: _budgetCodeController.text,
          items: _items,
          totalAmount: _items.fold(0, (sum, item) => sum + item.totalPrice),
          currency: 'KES',
          requiredDate: _requiredDate,
          urgency: _urgency,
          justification: _justificationController.text,
          expectedOutcomes: _expectedOutcomesController.text,
          alternativeConsidered: _alternativeConsideredController.text,
          status: widget.existingRequisition?.status ?? 'draft',
          currentApproverId: widget.existingRequisition?.currentApproverId,
          currentApproverName: widget.existingRequisition?.currentApproverName,
          approvalHistory: widget.existingRequisition?.approvalHistory ?? [],
          nextAction: widget.existingRequisition?.nextAction,
          procurementType: _procurementType,
          category: _categoryController.text,
          estimatedValue: _items.fold(0, (sum, item) => sum + item.totalPrice),
          relatedProject: widget.existingRequisition?.relatedProject,
          relatedTenderId: widget.existingRequisition?.relatedTenderId,
          requestedById: '', // Will be set by backend
          requestedByName: '',
          createdAt: widget.existingRequisition?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.existingRequisition == null) {
          await ref.read(purchaseRequisitionProvider.notifier).createRequisition(requisition);
        } else {
          await ref.read(purchaseRequisitionDetailProvider(widget.existingRequisition!.id).notifier).updateRequisition(requisition);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase requisition saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save requisition: $e')),
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

class AddRequisitionItemDialog extends StatefulWidget {
  final Function(RequisitionItem) onSave;

  const AddRequisitionItemDialog({super.key, required this.onSave});

  @override
  State<AddRequisitionItemDialog> createState() => _AddRequisitionItemDialogState();
}

class _AddRequisitionItemDialogState extends State<AddRequisitionItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _specificationsController = TextEditingController();
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Requisition Item'),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _specificationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Specifications',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter specifications';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Date'),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_deliveryDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = RequisitionItem(
        itemCode: _itemCodeController.text,
        description: _descriptionController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
        unitPrice: double.parse(_unitPriceController.text),
        totalPrice: double.parse(_quantityController.text) * double.parse(_unitPriceController.text),
        specifications: _specificationsController.text,
        deliveryDate: _deliveryDate,
      );
      widget.onSave(item);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
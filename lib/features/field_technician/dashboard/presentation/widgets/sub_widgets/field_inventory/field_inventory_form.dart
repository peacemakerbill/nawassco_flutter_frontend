import 'package:flutter/material.dart';
import '../../../../models/field_inventory.dart';

enum FormMode { create, edit }

class FieldInventoryFormView extends StatefulWidget {
  final FormMode mode;
  final FieldInventory? initialData;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const FieldInventoryFormView({
    super.key,
    required this.mode,
    this.initialData,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<FieldInventoryFormView> createState() => _FieldInventoryFormViewState();
}

class _FieldInventoryFormViewState extends State<FieldInventoryFormView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final List<InventorySpecification> _specifications = [];
  final List<String> _compatibleTools = [];

  // Form controllers
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _maximumStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQuantityController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _shelfNumberController = TextEditingController();
  final _binNumberController = TextEditingController();

  // Supplier controllers
  final _supplierNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _supplierPhoneController = TextEditingController();
  final _supplierEmailController = TextEditingController();
  final _leadTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeForm();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    _itemCodeController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _maximumStockController.dispose();
    _unitController.dispose();
    _unitCostController.dispose();
    _reorderPointController.dispose();
    _reorderQuantityController.dispose();
    _storageLocationController.dispose();
    _shelfNumberController.dispose();
    _binNumberController.dispose();
    _supplierNameController.dispose();
    _contactPersonController.dispose();
    _supplierPhoneController.dispose();
    _supplierEmailController.dispose();
    _leadTimeController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _itemNameController.text = data.itemName;
      _descriptionController.text = data.description;
      _itemCodeController.text = data.itemCode;
      _categoryController.text = data.category;
      _subcategoryController.text = data.subcategory;
      _currentStockController.text = data.currentStock.toString();
      _minimumStockController.text = data.minimumStock.toString();
      _maximumStockController.text = data.maximumStock.toString();
      _unitController.text = data.unit;
      _unitCostController.text = data.unitCost.toString();
      _reorderPointController.text = data.reorderPoint.toString();
      _reorderQuantityController.text = data.reorderQuantity.toString();
      _storageLocationController.text = data.storageLocation;
      _shelfNumberController.text = data.shelfNumber ?? '';
      _binNumberController.text = data.binNumber ?? '';

      // Supplier
      _supplierNameController.text = data.supplier.name;
      _contactPersonController.text = data.supplier.contactPerson;
      _supplierPhoneController.text = data.supplier.phone;
      _supplierEmailController.text = data.supplier.email;
      _leadTimeController.text = data.supplier.leadTime.toString();

      // Specifications
      _specifications.addAll(data.specifications);
      _compatibleTools.addAll(data.compatibleTools);
    }
  }

  void _addSpecification() {
    showDialog(
      context: context,
      builder: (context) => AddSpecificationDialog(
        onAdd: (spec) {
          setState(() => _specifications.add(spec));
        },
      ),
    );
  }

  void _removeSpecification(int index) {
    setState(() => _specifications.removeAt(index));
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'itemName': _itemNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'itemCode': _itemCodeController.text.trim(),
        'category': _categoryController.text.trim(),
        'subcategory': _subcategoryController.text.trim(),
        'currentStock': int.tryParse(_currentStockController.text) ?? 0,
        'minimumStock': int.tryParse(_minimumStockController.text) ?? 0,
        'maximumStock': int.tryParse(_maximumStockController.text) ?? 0,
        'unit': _unitController.text.trim(),
        'unitCost': double.tryParse(_unitCostController.text) ?? 0.0,
        'reorderPoint': int.tryParse(_reorderPointController.text) ?? 0,
        'reorderQuantity': int.tryParse(_reorderQuantityController.text) ?? 0,
        'storageLocation': _storageLocationController.text.trim(),
        'shelfNumber': _shelfNumberController.text.trim(),
        'binNumber': _binNumberController.text.trim(),
        'supplier': {
          'name': _supplierNameController.text.trim(),
          'contactPerson': _contactPersonController.text.trim(),
          'phone': _supplierPhoneController.text.trim(),
          'email': _supplierEmailController.text.trim(),
          'leadTime': int.tryParse(_leadTimeController.text) ?? 0,
        },
        'specifications': _specifications.map((s) => s.toJson()).toList(),
        'compatibleTools': _compatibleTools,
        'isActive': true,
      };

      widget.onSave(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.mode == FormMode.create
              ? 'Add New Inventory Item'
              : 'Edit Inventory Item',
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Basic Info'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Stock'),
            Tab(icon: Icon(Icons.business), text: 'Supplier'),
            Tab(icon: Icon(Icons.settings), text: 'Advanced'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildStockTab(),
            _buildSupplierTab(),
            _buildAdvancedTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        icon: const Icon(Icons.save),
        label: Text(
            widget.mode == FormMode.create ? 'Create Item' : 'Update Item'),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _itemNameController,
            decoration: const InputDecoration(
              labelText: 'Item Name *',
              prefixIcon: Icon(Icons.label),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _itemCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Item Code *',
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoryController.text.isNotEmpty
                      ? _categoryController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: InventoryCategoryEnum.values.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 16),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _categoryController.text = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select category';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subcategoryController,
            decoration: const InputDecoration(
              labelText: 'Subcategory',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _currentStockController,
                  decoration: const InputDecoration(
                    labelText: 'Current Stock *',
                    prefixIcon: Icon(Icons.inventory_2),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    hintText: 'pcs, kg, liters, etc.',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minimumStockController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stock *',
                    prefixIcon: Icon(Icons.arrow_downward),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter minimum stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maximumStockController,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Stock *',
                    prefixIcon: Icon(Icons.arrow_upward),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter maximum stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _unitCostController,
            decoration: const InputDecoration(
              labelText: 'Unit Cost (KES) *',
              prefixIcon: Icon(Icons.monetization_on),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter unit cost';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _reorderPointController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder Point *',
                    prefixIcon: Icon(Icons.warning),
                    border: OutlineInputBorder(),
                    hintText: 'Alert when stock reaches',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reorder point';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _reorderQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder Quantity *',
                    prefixIcon: Icon(Icons.shopping_cart),
                    border: OutlineInputBorder(),
                    hintText: 'Quantity to reorder',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reorder quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _supplierNameController,
            decoration: const InputDecoration(
              labelText: 'Supplier Name *',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter supplier name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactPersonController,
            decoration: const InputDecoration(
              labelText: 'Contact Person *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact person';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _supplierPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _supplierEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _leadTimeController,
            decoration: const InputDecoration(
              labelText: 'Lead Time (days) *',
              prefixIcon: Icon(Icons.schedule),
              border: OutlineInputBorder(),
              suffixText: 'days',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter lead time';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _storageLocationController,
            decoration: const InputDecoration(
              labelText: 'Storage Location *',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
              hintText: 'Warehouse A, Room 101, etc.',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter storage location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _shelfNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Shelf Number',
                    prefixIcon: Icon(Icons.grid_view),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _binNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bin Number',
                    prefixIcon: Icon(Icons.grid_3x3),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Specifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addSpecification,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Specification'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_specifications.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.settings, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No specifications added',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._specifications.asMap().entries.map((entry) {
              final index = entry.key;
              final spec = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.tune, color: Colors.blue),
                  title: Text(spec.parameter),
                  subtitle: Text('${spec.value} ${spec.unit}'),
                  trailing: IconButton(
                    onPressed: () => _removeSpecification(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class AddSpecificationDialog extends StatefulWidget {
  final Function(InventorySpecification) onAdd;

  const AddSpecificationDialog({super.key, required this.onAdd});

  @override
  State<AddSpecificationDialog> createState() => _AddSpecificationDialogState();
}

class _AddSpecificationDialogState extends State<AddSpecificationDialog> {
  final _parameterController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _parameterController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _addSpecification() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(InventorySpecification(
        parameter: _parameterController.text.trim(),
        value: _valueController.text.trim(),
        unit: _unitController.text.trim(),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Specification'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _parameterController,
              decoration: const InputDecoration(
                labelText: 'Parameter *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parameter';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Value *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit *',
                border: OutlineInputBorder(),
                hintText: 'mm, kg, psi, etc.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter unit';
                }
                return null;
              },
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
          onPressed: _addSpecification,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/inventory/inventory_item_model.dart';
import '../../../../providers/inventory_item_provider.dart';

class AddEditItemDialog extends ConsumerStatefulWidget {
  final InventoryItem? item;
  final VoidCallback onSaved;

  const AddEditItemDialog({
    super.key,
    this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends ConsumerState<AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _maximumStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQuantityController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _binLocationController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _zoneController = TextEditingController();
  final _rackController = TextEditingController();
  final _shelfController = TextEditingController();
  final _positionController = TextEditingController();

  String _selectedCategory = 'pipes_fittings';
  String _selectedItemType = 'raw_material';
  String _selectedMovementClass = 'slow_moving';
  String _selectedStatus = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.item != null) {
      final item = widget.item!;
      _itemCodeController.text = item.itemCode;
      _itemNameController.text = item.itemName;
      _descriptionController.text = item.description;
      _subCategoryController.text = item.subCategory;
      _unitOfMeasureController.text = item.unitOfMeasure;
      _currentStockController.text = item.currentStock.toString();
      _minimumStockController.text = item.minimumStock.toString();
      _maximumStockController.text = item.maximumStock.toString();
      _reorderPointController.text = item.reorderPoint.toString();
      _reorderQuantityController.text = item.reorderQuantity.toString();
      _costPriceController.text = item.costPrice.toString();
      _sellingPriceController.text = item.sellingPrice.toString();
      _binLocationController.text = item.binLocation;
      _warehouseController.text = item.storageLocation.warehouse;
      _zoneController.text = item.storageLocation.zone;
      _rackController.text = item.storageLocation.rack;
      _shelfController.text = item.storageLocation.shelf;
      _positionController.text = item.storageLocation.position;

      _selectedCategory = item.category;
      _selectedItemType = item.itemType;
      _selectedMovementClass = item.movementClass;
      _selectedStatus = item.status;
    } else {
      _unitOfMeasureController.text = 'Piece';
      _currentStockController.text = '0';
      _minimumStockController.text = '10';
      _maximumStockController.text = '100';
      _reorderPointController.text = '20';
      _reorderQuantityController.text = '50';
      _costPriceController.text = '0';
      _sellingPriceController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item'),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveItem,
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionHeader('Basic Information'),
                    _buildBasicInfoSection(),

                    const SizedBox(height: 20),

                    // Stock Information
                    _buildSectionHeader('Stock Information'),
                    _buildStockInfoSection(),

                    const SizedBox(height: 20),

                    // Pricing
                    _buildSectionHeader('Pricing'),
                    _buildPricingSection(),

                    const SizedBox(height: 20),

                    // Storage Location
                    _buildSectionHeader('Storage Location'),
                    _buildStorageLocationSection(),

                    const SizedBox(height: 20),

                    // Classification
                    _buildSectionHeader('Classification'),
                    _buildClassificationSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildTextField(
          controller: _itemCodeController,
          label: 'Item Code *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Item code is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _itemNameController,
          label: 'Item Name *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Item name is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description *',
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _subCategoryController,
          label: 'Sub Category *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sub category is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStockInfoSection() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildTextField(
          controller: _currentStockController,
          label: 'Current Stock',
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller: _minimumStockController,
          label: 'Minimum Stock *',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Minimum stock is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _maximumStockController,
          label: 'Maximum Stock *',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Maximum stock is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _reorderPointController,
          label: 'Reorder Point *',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Reorder point is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _reorderQuantityController,
          label: 'Reorder Quantity *',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Reorder quantity is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _unitOfMeasureController,
          label: 'Unit of Measure *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Unit of measure is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildTextField(
          controller: _costPriceController,
          label: 'Cost Price *',
          keyboardType: TextInputType.number,
          prefixText: 'KES ',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Cost price is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _sellingPriceController,
          label: 'Selling Price *',
          keyboardType: TextInputType.number,
          prefixText: 'KES ',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selling price is required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStorageLocationSection() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildTextField(
          controller: _warehouseController,
          label: 'Warehouse *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Warehouse is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _zoneController,
          label: 'Zone *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Zone is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _rackController,
          label: 'Rack *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Rack is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _shelfController,
          label: 'Shelf *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Shelf is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _positionController,
          label: 'Position *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Position is required';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _binLocationController,
          label: 'Bin Location *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bin location is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildClassificationSection() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      children: [
        _buildDropdown(
          value: _selectedCategory,
          label: 'Category *',
          items: InventoryCategoryEnum.values.map((e) {
            return DropdownMenuItem(
              value: e.value,
              child: Text(e.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        _buildDropdown(
          value: _selectedItemType,
          label: 'Item Type *',
          items: ItemType.values.map((e) {
            return DropdownMenuItem(
              value: e.value,
              child: Text(e.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedItemType = value!;
            });
          },
        ),
        _buildDropdown(
          value: _selectedMovementClass,
          label: 'Movement Class',
          items: MovementClass.values.map((e) {
            return DropdownMenuItem(
              value: e.value,
              child: Text(e.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMovementClass = value!;
            });
          },
        ),
        _buildDropdown(
          value: _selectedStatus,
          label: 'Status',
          items: ItemStatus.values.map((e) {
            return DropdownMenuItem(
              value: e.value,
              child: Text(e.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final item = InventoryItem(
        id: widget.item?.id ?? '',
        itemCode: _itemCodeController.text.trim().toUpperCase(),
        itemName: _itemNameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        subCategory: _subCategoryController.text.trim(),
        itemType: _selectedItemType,
        unitOfMeasure: _unitOfMeasureController.text.trim(),
        specifications: widget.item?.specifications ?? [],
        technicalDetails: widget.item?.technicalDetails ?? [],
        compatibility: widget.item?.compatibility ?? [],
        currentStock: double.parse(_currentStockController.text),
        minimumStock: double.parse(_minimumStockController.text),
        maximumStock: double.parse(_maximumStockController.text),
        reorderPoint: double.parse(_reorderPointController.text),
        reorderQuantity: double.parse(_reorderQuantityController.text),
        economicOrderQuantity: widget.item?.economicOrderQuantity ?? 0,
        storageLocation: StorageLocation(
          warehouse: _warehouseController.text.trim(),
          zone: _zoneController.text.trim(),
          rack: _rackController.text.trim(),
          shelf: _shelfController.text.trim(),
          position: _positionController.text.trim(),
        ),
        binLocation: _binLocationController.text.trim(),
        storageRequirements: widget.item?.storageRequirements ?? [],
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        averageCost: widget.item?.averageCost ?? double.parse(_costPriceController.text),
        lastPurchasePrice: widget.item?.lastPurchasePrice ?? double.parse(_costPriceController.text),
        currency: 'KES',
        preferredSupplier: widget.item?.preferredSupplier ?? '',
        alternativeSuppliers: widget.item?.alternativeSuppliers ?? [],
        leadTime: widget.item?.leadTime ?? 7,
        usageRate: widget.item?.usageRate ?? 0,
        movementClass: _selectedMovementClass,
        lastMovementDate: widget.item?.lastMovementDate,
        annualUsage: widget.item?.annualUsage ?? 0,
        qualityRequirements: widget.item?.qualityRequirements ?? [],
        certifications: widget.item?.certifications ?? [],
        expiryManagement: widget.item?.expiryManagement ?? ExpiryManagement(
          hasExpiry: false,
          shelfLife: 0,
          alertBefore: 30,
        ),
        status: _selectedStatus,
        isActive: true,
        createdBy: widget.item?.createdBy ?? '',
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.item == null) {
        await ref.read(inventoryItemProvider.notifier).createInventoryItem(item);
      } else {
        await ref.read(inventoryItemProvider.notifier).updateInventoryItem(item.id, item);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.item == null
                    ? 'Item created successfully'
                    : 'Item updated successfully'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    _subCategoryController.dispose();
    _unitOfMeasureController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _maximumStockController.dispose();
    _reorderPointController.dispose();
    _reorderQuantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _binLocationController.dispose();
    _warehouseController.dispose();
    _zoneController.dispose();
    _rackController.dispose();
    _shelfController.dispose();
    _positionController.dispose();
    super.dispose();
  }
}
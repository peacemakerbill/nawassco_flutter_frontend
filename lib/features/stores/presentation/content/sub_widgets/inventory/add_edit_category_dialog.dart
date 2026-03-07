import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/inventory/inventory_category_model.dart';
import '../../../../providers/inventory_category_provider.dart';


class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final InventoryCategory? category;
  final VoidCallback onSaved;

  const AddEditCategoryDialog({
    super.key,
    this.category,
    required this.onSaved,
  });

  @override
  ConsumerState<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryCodeController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _parentCategoryController = TextEditingController();
  final _characteristicController = TextEditingController();
  final _storageRequirementController = TextEditingController();
  final _handlingInstructionController = TextEditingController();

  final List<String> _characteristics = [];
  final List<String> _storageRequirements = [];
  final List<String> _handlingInstructions = [];

  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.category != null) {
      final category = widget.category!;
      _categoryCodeController.text = category.categoryCode;
      _categoryNameController.text = category.categoryName;
      _descriptionController.text = category.description;
      _parentCategoryController.text = category.parentCategory ?? '';
      _characteristics.addAll(category.characteristics);
      _storageRequirements.addAll(category.storageRequirements);
      _handlingInstructions.addAll(category.handlingInstructions);
      _isActive = category.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                  onPressed: _saveCategory,
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

                    // Characteristics
                    _buildSectionHeader('Characteristics'),
                    _buildListSection(
                      controller: _characteristicController,
                      items: _characteristics,
                      onAdd: _addCharacteristic,
                      onRemove: _removeCharacteristic,
                      hintText: 'Add characteristic...',
                    ),

                    const SizedBox(height: 20),

                    // Storage Requirements
                    _buildSectionHeader('Storage Requirements'),
                    _buildListSection(
                      controller: _storageRequirementController,
                      items: _storageRequirements,
                      onAdd: _addStorageRequirement,
                      onRemove: _removeStorageRequirement,
                      hintText: 'Add storage requirement...',
                    ),

                    const SizedBox(height: 20),

                    // Handling Instructions
                    _buildSectionHeader('Handling Instructions'),
                    _buildListSection(
                      controller: _handlingInstructionController,
                      items: _handlingInstructions,
                      onAdd: _addHandlingInstruction,
                      onRemove: _removeHandlingInstruction,
                      hintText: 'Add handling instruction...',
                    ),

                    const SizedBox(height: 20),

                    // Status
                    _buildStatusSection(),
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _categoryCodeController,
          label: 'Category Code *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Category code is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _categoryNameController,
          label: 'Category Name *',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Category name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description *',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _parentCategoryController,
          label: 'Parent Category',
        ),
      ],
    );
  }

  Widget _buildListSection({
    required TextEditingController controller,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required String hintText,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onAdd();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onAdd();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.circle, size: 8),
                  title: Text(items[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () => onRemove(index),
                  ),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        Checkbox(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value ?? true;
            });
          },
        ),
        const Text('Active Category'),
        const Spacer(),
        Text(
          _isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            color: _isActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _addCharacteristic() {
    setState(() {
      _characteristics.add(_characteristicController.text.trim());
      _characteristicController.clear();
    });
  }

  void _removeCharacteristic(int index) {
    setState(() {
      _characteristics.removeAt(index);
    });
  }

  void _addStorageRequirement() {
    setState(() {
      _storageRequirements.add(_storageRequirementController.text.trim());
      _storageRequirementController.clear();
    });
  }

  void _removeStorageRequirement(int index) {
    setState(() {
      _storageRequirements.removeAt(index);
    });
  }

  void _addHandlingInstruction() {
    setState(() {
      _handlingInstructions.add(_handlingInstructionController.text.trim());
      _handlingInstructionController.clear();
    });
  }

  void _removeHandlingInstruction(int index) {
    setState(() {
      _handlingInstructions.removeAt(index);
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final category = InventoryCategory(
        id: widget.category?.id ?? '',
        categoryCode: _categoryCodeController.text.trim().toUpperCase(),
        categoryName: _categoryNameController.text.trim(),
        description: _descriptionController.text.trim(),
        parentCategory: _parentCategoryController.text.trim().isEmpty
            ? null
            : _parentCategoryController.text.trim(),
        characteristics: _characteristics,
        storageRequirements: _storageRequirements,
        handlingInstructions: _handlingInstructions,
        isActive: _isActive,
        createdBy: widget.category?.createdBy ?? '',
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.category == null) {
        await ref.read(inventoryCategoryProvider.notifier).createCategory(category);
      } else {
        await ref.read(inventoryCategoryProvider.notifier).updateCategory(category.id, category);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.category == null
                    ? 'Category created successfully'
                    : 'Category updated successfully'
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
    _categoryCodeController.dispose();
    _categoryNameController.dispose();
    _descriptionController.dispose();
    _parentCategoryController.dispose();
    _characteristicController.dispose();
    _storageRequirementController.dispose();
    _handlingInstructionController.dispose();
    super.dispose();
  }
}
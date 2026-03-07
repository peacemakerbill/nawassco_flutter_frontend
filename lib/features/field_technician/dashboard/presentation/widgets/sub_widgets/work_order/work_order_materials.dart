import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/work_order.dart';
import '../../../../providers/work_order_provider.dart';

class WorkOrderMaterials extends ConsumerStatefulWidget {
  final WorkOrder workOrder;

  const WorkOrderMaterials({super.key, required this.workOrder});

  @override
  ConsumerState<WorkOrderMaterials> createState() => _WorkOrderMaterialsState();
}

class _WorkOrderMaterialsState extends ConsumerState<WorkOrderMaterials>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'Required Materials'),
              Tab(text: 'Materials Used'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequiredMaterialsTab(),
              _buildMaterialsUsedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredMaterialsTab() {
    final requiredMaterials = widget.workOrder.requiredMaterials;
    final currencyFormat = NumberFormat.currency(symbol: 'KES ');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Materials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${requiredMaterials.length} items required',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currencyFormat.format(_calculateRequiredMaterialsCost()),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: requiredMaterials.isEmpty
              ? _buildEmptyRequiredMaterials()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requiredMaterials.length,
                  itemBuilder: (context, index) => _buildRequiredMaterialItem(
                      requiredMaterials[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: ElevatedButton.icon(
            onPressed: _addRequiredMaterial,
            icon: const Icon(Icons.add),
            label: const Text('Add Required Material'),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsUsedTab() {
    final materialsUsed = widget.workOrder.materialsUsed;
    final currencyFormat = NumberFormat.currency(symbol: 'KES ');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Materials Used',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${materialsUsed.length} items used',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currencyFormat.format(_calculateMaterialsUsedCost()),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: materialsUsed.isEmpty
              ? _buildEmptyMaterialsUsed()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materialsUsed.length,
                  itemBuilder: (context, index) =>
                      _buildMaterialUsedItem(materialsUsed[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: ElevatedButton.icon(
            onPressed: _recordMaterialUsage,
            icon: const Icon(Icons.inventory),
            label: const Text('Record Material Usage'),
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredMaterialItem(RequiredMaterial material, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.materialName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (material.specifications != null)
                        Text(
                          material.specifications!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handleRequiredMaterialAction(value, index),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'mark_used', child: Text('Mark as Used')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  Icons.scale,
                  'Quantity: ${material.quantity} ${material.unit}',
                ),
                _buildDetailChip(
                  Icons.inventory_2,
                  'Material ID: ${material.materialId}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialUsedItem(MaterialUsage material, int index) {
    final currencyFormat = NumberFormat.currency(symbol: 'KES ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.materialName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(material.cost),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handleMaterialUsedAction(value, index),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  Icons.scale,
                  'Used: ${material.quantityUsed} ${material.unit}',
                ),
                if (material.batchNumber != null)
                  _buildDetailChip(
                    Icons.qr_code,
                    'Batch: ${material.batchNumber}',
                  ),
                _buildDetailChip(
                  Icons.attach_money,
                  'Cost: ${NumberFormat.currency(symbol: 'KES ').format(material.cost)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequiredMaterials() {
    return Center(
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
            'No Required Materials',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add materials that are required for this work order',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMaterialsUsed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Materials Used',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Record materials as you use them during the work',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  double _calculateRequiredMaterialsCost() {
    return widget.workOrder.estimatedCost * 0.6;
  }

  double _calculateMaterialsUsedCost() {
    return widget.workOrder.materialsUsed.fold<double>(
      0,
      (sum, material) => sum + material.cost,
    );
  }

  void _addRequiredMaterial() {
    showDialog(
      context: context,
      builder: (context) => RequiredMaterialDialog(
        onSave: (materialData) {
          _showFeatureNotAvailable();
        },
      ),
    );
  }

  void _recordMaterialUsage() {
    showDialog(
      context: context,
      builder: (context) => MaterialUsageDialog(
        onSave: (usageData) {
          ref.read(workOrderProvider.notifier).recordMaterialUsage(
                widget.workOrder.id,
                usageData,
              );
        },
      ),
    );
  }

  void _handleRequiredMaterialAction(String action, int index) {
    switch (action) {
      case 'edit':
        _editRequiredMaterial(index);
        break;
      case 'mark_used':
        _markAsUsed(index);
        break;
      case 'delete':
        _deleteRequiredMaterial(index);
        break;
    }
  }

  void _handleMaterialUsedAction(String action, int index) {
    switch (action) {
      case 'edit':
        _editMaterialUsed(index);
        break;
      case 'delete':
        _deleteMaterialUsed(index);
        break;
    }
  }

  void _editRequiredMaterial(int index) {
    _showFeatureNotAvailable();
  }

  void _markAsUsed(int index) {
    final material = widget.workOrder.requiredMaterials[index];
    showDialog(
      context: context,
      builder: (context) => MaterialUsageDialog(
        material: material,
        onSave: (usageData) {
          ref.read(workOrderProvider.notifier).recordMaterialUsage(
                widget.workOrder.id,
                usageData,
              );
        },
      ),
    );
  }

  void _deleteRequiredMaterial(int index) {
    _showFeatureNotAvailable();
  }

  void _editMaterialUsed(int index) {
    _showFeatureNotAvailable();
  }

  void _deleteMaterialUsed(int index) {
    _showFeatureNotAvailable();
  }

  void _showFeatureNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature will be available in the next update'),
      ),
    );
  }
}

class RequiredMaterialDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const RequiredMaterialDialog({super.key, required this.onSave});

  @override
  State<RequiredMaterialDialog> createState() => _RequiredMaterialDialogState();
}

class _RequiredMaterialDialogState extends State<RequiredMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialNameController = TextEditingController();
  final _materialIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _specificationsController = TextEditingController();

  @override
  void dispose() {
    _materialNameController.dispose();
    _materialIdController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _specificationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Required Material'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _materialNameController,
              decoration: const InputDecoration(
                labelText: 'Material Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter material name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materialIdController,
              decoration: const InputDecoration(
                labelText: 'Material ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter material ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
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
              controller: _specificationsController,
              decoration: const InputDecoration(
                labelText: 'Specifications (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: _saveMaterial,
          child: const Text('Add Material'),
        ),
      ],
    );
  }

  void _saveMaterial() {
    if (_formKey.currentState!.validate()) {
      final materialData = {
        'material': _materialIdController.text,
        'materialName': _materialNameController.text,
        'quantity': int.parse(_quantityController.text),
        'unit': _unitController.text,
        if (_specificationsController.text.isNotEmpty)
          'specifications': _specificationsController.text,
      };

      widget.onSave(materialData);
      Navigator.pop(context);
    }
  }
}

class MaterialUsageDialog extends StatefulWidget {
  final RequiredMaterial? material;
  final Function(Map<String, dynamic>) onSave;

  const MaterialUsageDialog({
    super.key,
    this.material,
    required this.onSave,
  });

  @override
  State<MaterialUsageDialog> createState() => _MaterialUsageDialogState();
}

class _MaterialUsageDialogState extends State<MaterialUsageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialNameController = TextEditingController();
  final _materialIdController = TextEditingController();
  final _quantityUsedController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  final _batchNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _materialNameController.text = widget.material!.materialName;
      _materialIdController.text = widget.material!.materialId;
      _quantityUsedController.text = widget.material!.quantity.toString();
      _unitController.text = widget.material!.unit;
    }
  }

  @override
  void dispose() {
    _materialNameController.dispose();
    _materialIdController.dispose();
    _quantityUsedController.dispose();
    _unitController.dispose();
    _costController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Material Usage'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _materialNameController,
              decoration: const InputDecoration(
                labelText: 'Material Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter material name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materialIdController,
              decoration: const InputDecoration(
                labelText: 'Material ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter material ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityUsedController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity Used',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
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
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch Number (optional)',
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
          onPressed: _saveUsage,
          child: const Text('Record Usage'),
        ),
      ],
    );
  }

  void _saveUsage() {
    if (_formKey.currentState!.validate()) {
      final usageData = {
        'material': _materialIdController.text,
        'materialName': _materialNameController.text,
        'quantityUsed': int.parse(_quantityUsedController.text),
        'unit': _unitController.text,
        'cost': double.parse(_costController.text),
        if (_batchNumberController.text.isNotEmpty)
          'batchNumber': _batchNumberController.text,
      };

      widget.onSave(usageData);
      Navigator.pop(context);
    }
  }
}

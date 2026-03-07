import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_catalog_model.dart';
import '../../../utils/service_catalog/service_constants.dart';

class ServiceFormWidget extends ConsumerStatefulWidget {
  final ServiceCatalog? initialData;
  final Function(Map<String, dynamic>)? onSubmit;
  final VoidCallback? onCancel;

  const ServiceFormWidget({
    super.key,
    this.initialData,
    this.onSubmit,
    this.onCancel,
  });

  @override
  ConsumerState<ServiceFormWidget> createState() => _ServiceFormWidgetState();
}

class _ServiceFormWidgetState extends ConsumerState<ServiceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceCodeController = TextEditingController();
  final _typeController = TextEditingController();
  final _basePriceController = TextEditingController();

  ServiceCategory _selectedCategory = ServiceCategory.waterServices;
  ServiceStatus _selectedStatus = ServiceStatus.active;
  String _selectedPricingModel = 'Fixed';

  final List<CustomerType> _selectedCustomerTypes = [CustomerType.residential];
  final List<String> _selectedAreas = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.name;
      _descriptionController.text = widget.initialData!.description;
      _serviceCodeController.text = widget.initialData!.serviceCode;
      _typeController.text = widget.initialData!.type;
      _basePriceController.text =
          widget.initialData!.pricing.basePrice.toString();
      _selectedCategory = widget.initialData!.category;
      _selectedStatus = widget.initialData!.status;
      _selectedPricingModel = widget.initialData!.pricing.pricingModel;
      _selectedCustomerTypes.clear();
      _selectedCustomerTypes
          .addAll(widget.initialData!.eligibility.customerTypes);
      _selectedAreas.clear();
      _selectedAreas.addAll(widget.initialData!.availableAreas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.add_circle, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  widget.initialData == null
                      ? 'Create New Service'
                      : 'Edit Service',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Basic Information Section
            _buildSection(
              title: 'Basic Information',
              icon: Icons.info,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    hintText: 'e.g., New Water Connection',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
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
                    hintText: 'Describe the service in detail...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    if (value.length < 20) {
                      return 'Description should be at least 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ServiceCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ServiceCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon,
                                    color: category.color, size: 16),
                                const SizedBox(width: 8),
                                Text(category.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _serviceCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Service Code',
                          hintText: 'Auto-generated',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.initialData != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ServiceStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ServiceStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  ServiceConstants.getStatusIcon(
                                      status.displayName),
                                  color: ServiceConstants.getStatusColor(
                                      status.displayName),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                          hintText: 'e.g., New Connection',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pricing Section
            _buildSection(
              title: 'Pricing',
              icon: Icons.monetization_on,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _basePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Base Price (KES)',
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                          prefixText: 'KES ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter base price';
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedPricingModel,
                        decoration: const InputDecoration(
                          labelText: 'Pricing Model',
                          border: OutlineInputBorder(),
                        ),
                        items: ServiceConstants.pricingModels.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(model),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPricingModel = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Eligibility Section
            _buildSection(
              title: 'Eligibility',
              icon: Icons.verified_user,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CustomerType.values.map((type) {
                    final isSelected = _selectedCustomerTypes.contains(type);
                    return FilterChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCustomerTypes.add(type);
                          } else {
                            _selectedCustomerTypes.remove(type);
                          }
                        });
                      },
                      avatar: Icon(type.icon, size: 16),
                      selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: theme.primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Available Areas',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ServiceConstants.popularAreas.map((area) {
                    final isSelected = _selectedAreas.contains(area);
                    return FilterChip(
                      label: Text(area),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAreas.add(area);
                          } else {
                            _selectedAreas.remove(area);
                          }
                        });
                      },
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      checkmarkColor: Colors.green,
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Service'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'serviceCode': _serviceCodeController.text.isEmpty
            ? null
            : _serviceCodeController.text,
        'category': _selectedCategory.name,
        'type': _typeController.text,
        'status': _selectedStatus.name,
        'pricing': {
          'pricingModel': _selectedPricingModel.toLowerCase(),
          'basePrice': double.parse(_basePriceController.text),
          'currency': 'KES',
          'variableComponents': [],
          'taxes': [],
          'discounts': [],
        },
        'eligibility': {
          'customerTypes': _selectedCustomerTypes.map((e) => e.name).toList(),
          'propertyTypes': [],
          'prerequisites': [],
          'documentationRequired': [],
        },
        'availableAreas': _selectedAreas,
      };

      widget.onSubmit?.call(data);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _serviceCodeController.dispose();
    _typeController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }
}

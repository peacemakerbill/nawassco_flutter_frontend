import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/fixed_asset_model.dart';
import '../../../../providers/fixed_asset_provider.dart';

class FixedAssetForm extends ConsumerStatefulWidget {
  final FixedAsset? initialAsset;

  const FixedAssetForm({super.key, this.initialAsset});

  @override
  ConsumerState<FixedAssetForm> createState() => _FixedAssetFormState();
}

class _FixedAssetFormState extends ConsumerState<FixedAssetForm> {
  final _formKey = GlobalKey<FormState>();
  final _assetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _acquisitionCostController = TextEditingController();
  final _usefulLifeController = TextEditingController();
  final _salvageValueController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _insuranceValueController = TextEditingController();
  final _supplierNameController = TextEditingController();      // New
  final _purchaseOrderNumberController = TextEditingController(); // New

  AssetCategory _selectedCategory = AssetCategory.equipment;
  DepreciationMethod _selectedDepreciationMethod =
      DepreciationMethod.straight_line;
  DateTime _acquisitionDate = DateTime.now();
  DateTime? _insuranceExpiry;
  bool _insured = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAsset != null) {
      _initializeForm(widget.initialAsset!);
    }
  }

  void _initializeForm(FixedAsset asset) {
    _assetNameController.text = asset.assetName;
    _descriptionController.text = asset.description;
    _acquisitionCostController.text = asset.acquisitionCost.toString();
    _usefulLifeController.text = asset.usefulLife.toString();
    _salvageValueController.text = asset.salvageValue.toString();
    _locationController.text = asset.location;
    _departmentController.text = asset.department;
    _insuranceValueController.text = asset.insuranceValue?.toString() ?? '';
    _supplierNameController.text = asset.supplierName ?? '';            // New
    _purchaseOrderNumberController.text = asset.purchaseOrderNumber ?? ''; // New

    _selectedCategory = asset.assetCategory;
    _selectedDepreciationMethod = asset.depreciationMethod;
    _acquisitionDate = asset.acquisitionDate;
    _insured = asset.insured;
    _insuranceExpiry = asset.insuranceExpiry;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialAsset == null
                        ? 'Add New Fixed Asset'
                        : 'Edit Fixed Asset',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Basic Information
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 16),
                  _buildAssetNameField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),
                            _buildLocationField(),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: _buildCategoryDropdown()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildLocationField()),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildDepartmentField(),
                            const SizedBox(height: 16),
                            _buildAcquisitionDateField(),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: _buildDepartmentField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildAcquisitionDateField()),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Supplier & Purchase Order Information
                  _buildSectionHeader('Supplier & Purchase Order'),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildSupplierNameField(),
                            const SizedBox(height: 16),
                            _buildPurchaseOrderNumberField(),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: _buildSupplierNameField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPurchaseOrderNumberField()),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Financial Information
                  _buildSectionHeader('Financial Information'),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildAcquisitionCostField(),
                            const SizedBox(height: 16),
                            _buildDepreciationMethodDropdown(),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: _buildAcquisitionCostField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDepreciationMethodDropdown()),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildUsefulLifeField(),
                            const SizedBox(height: 16),
                            _buildSalvageValueField(),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(child: _buildUsefulLifeField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildSalvageValueField()),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Insurance Information
                  _buildSectionHeader('Insurance Information'),
                  const SizedBox(height: 16),
                  _buildInsuranceToggle(),
                  if (_insured) ...[
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildInsuranceValueField(),
                              const SizedBox(height: 16),
                              _buildInsuranceExpiryField(),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(child: _buildInsuranceValueField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInsuranceExpiryField()),
                            ],
                          );
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit Button
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.initialAsset == null
                            ? 'CREATE ASSET'
                            : 'UPDATE ASSET',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add these two new field methods:
  Widget _buildSupplierNameField() {
    return TextFormField(
      controller: _supplierNameController,
      decoration: const InputDecoration(
        labelText: 'Supplier Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
    );
  }

  Widget _buildPurchaseOrderNumberField() {
    return TextFormField(
      controller: _purchaseOrderNumberController,
      decoration: const InputDecoration(
        labelText: 'Purchase Order Number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
    );
  }

  // Keep all existing methods (they remain the same)
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 2,
          width: 24,
          color: const Color(0xFF0D47A1),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetNameField() {
    return TextFormField(
      controller: _assetNameController,
      decoration: const InputDecoration(
        labelText: 'Asset Name *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business_center),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter asset name';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description *',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter description';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<AssetCategory>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Asset Category *',
        border: OutlineInputBorder(),
      ),
      items: AssetCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(_getCategoryDisplayName(category)),
        );
      }).toList(),
      onChanged: (category) {
        if (category != null) {
          setState(() {
            _selectedCategory = category;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select category';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter location';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentField() {
    return TextFormField(
      controller: _departmentController,
      decoration: const InputDecoration(
        labelText: 'Department *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter department';
        }
        return null;
      },
    );
  }

  Widget _buildAcquisitionDateField() {
    return InkWell(
      onTap: () => _selectAcquisitionDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Acquisition Date *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          children: [
            Text(_acquisitionDate.toLocal().toString().split(' ')[0]),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildAcquisitionCostField() {
    return TextFormField(
      controller: _acquisitionCostController,
      decoration: const InputDecoration(
        labelText: 'Acquisition Cost (KES) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter acquisition cost';
        }
        final cost = double.tryParse(value);
        if (cost == null || cost <= 0) {
          return 'Please enter a valid cost';
        }
        return null;
      },
    );
  }

  Widget _buildDepreciationMethodDropdown() {
    return DropdownButtonFormField<DepreciationMethod>(
      value: _selectedDepreciationMethod,
      decoration: const InputDecoration(
        labelText: 'Depreciation Method *',
        border: OutlineInputBorder(),
      ),
      items: DepreciationMethod.values.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(_getDepreciationMethodDisplayName(method)),
        );
      }).toList(),
      onChanged: (method) {
        if (method != null) {
          setState(() {
            _selectedDepreciationMethod = method;
          });
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select depreciation method';
        }
        return null;
      },
    );
  }

  Widget _buildUsefulLifeField() {
    return TextFormField(
      controller: _usefulLifeController,
      decoration: const InputDecoration(
        labelText: 'Useful Life (Years) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter useful life';
        }
        final years = int.tryParse(value);
        if (years == null || years <= 0) {
          return 'Please enter a valid number of years';
        }
        return null;
      },
    );
  }

  Widget _buildSalvageValueField() {
    return TextFormField(
      controller: _salvageValueController,
      decoration: const InputDecoration(
        labelText: 'Salvage Value (KES)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.money_off),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final salvage = double.tryParse(value);
          if (salvage == null || salvage < 0) {
            return 'Please enter a valid salvage value';
          }
        }
        return null;
      },
    );
  }

  Widget _buildInsuranceToggle() {
    return Row(
      children: [
        Switch(
          value: _insured,
          onChanged: (value) {
            setState(() {
              _insured = value;
            });
          },
          activeColor: const Color(0xFF0D47A1),
        ),
        const SizedBox(width: 8),
        const Text(
          'Asset is Insured',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInsuranceValueField() {
    return TextFormField(
      controller: _insuranceValueController,
      decoration: const InputDecoration(
        labelText: 'Insurance Value (KES)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.security),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (_insured && (value == null || value.isEmpty)) {
          return 'Please enter insurance value';
        }
        if (value != null && value.isNotEmpty) {
          final insuranceValue = double.tryParse(value);
          if (insuranceValue == null || insuranceValue <= 0) {
            return 'Please enter a valid insurance value';
          }
        }
        return null;
      },
    );
  }

  Widget _buildInsuranceExpiryField() {
    return InkWell(
      onTap: _insured ? () => _selectInsuranceExpiry(context) : null,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Insurance Expiry Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          children: [
            Text(
              _insuranceExpiry != null
                  ? _insuranceExpiry!.toLocal().toString().split(' ')[0]
                  : 'Select date',
              style: TextStyle(
                color: _insured ? Colors.black : Colors.grey[400],
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAcquisitionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _acquisitionDate) {
      setState(() {
        _acquisitionDate = picked;
      });
    }
  }

  Future<void> _selectInsuranceExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
      _insuranceExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _insuranceExpiry) {
      setState(() {
        _insuranceExpiry = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final asset = FixedAsset(
        id: widget.initialAsset?.id ?? '',
        assetNumber: widget.initialAsset?.assetNumber ?? '',
        assetName: _assetNameController.text.trim(),
        description: _descriptionController.text.trim(),
        assetCategory: _selectedCategory,
        acquisitionDate: _acquisitionDate,
        acquisitionCost: double.parse(_acquisitionCostController.text),
        depreciationMethod: _selectedDepreciationMethod,
        usefulLife: int.parse(_usefulLifeController.text),
        salvageValue: double.parse(_salvageValueController.text.isEmpty
            ? '0'
            : _salvageValueController.text),
        supplierName: _supplierNameController.text.trim().isEmpty
            ? null
            : _supplierNameController.text.trim(),
        purchaseOrderNumber: _purchaseOrderNumberController.text.trim().isEmpty
            ? null
            : _purchaseOrderNumberController.text.trim(),
        currentBookValue: widget.initialAsset?.currentBookValue ??
            double.parse(_acquisitionCostController.text),
        accumulatedDepreciation:
        widget.initialAsset?.accumulatedDepreciation ?? 0,
        location: _locationController.text.trim(),
        department: _departmentController.text.trim(),
        status: widget.initialAsset?.status ?? AssetStatus.active,
        insured: _insured,
        insuranceValue:
        _insured ? double.tryParse(_insuranceValueController.text) : null,
        insuranceExpiry: _insured ? _insuranceExpiry : null,
        createdById: widget.initialAsset?.createdById ?? 'current_user_id',
        createdAt: widget.initialAsset?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.initialAsset == null
          ? await ref.read(fixedAssetsProvider.notifier).createAsset(asset)
          : await ref
          .read(fixedAssetsProvider.notifier)
          .updateAsset(widget.initialAsset!.id, asset);

      if (success && context.mounted) {
        if (widget.initialAsset == null) {
          _resetForm();
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _assetNameController.clear();
    _descriptionController.clear();
    _acquisitionCostController.clear();
    _usefulLifeController.clear();
    _salvageValueController.clear();
    _locationController.clear();
    _departmentController.clear();
    _insuranceValueController.clear();
    _supplierNameController.clear();           // New
    _purchaseOrderNumberController.clear();     // New

    setState(() {
      _selectedCategory = AssetCategory.equipment;
      _selectedDepreciationMethod = DepreciationMethod.straight_line;
      _acquisitionDate = DateTime.now();
      _insured = false;
      _insuranceExpiry = null;
    });
  }

  String _getCategoryDisplayName(AssetCategory category) {
    switch (category) {
      case AssetCategory.land:
        return 'Land';
      case AssetCategory.buildings:
        return 'Buildings';
      case AssetCategory.vehicles:
        return 'Vehicles';
      case AssetCategory.equipment:
        return 'Equipment';
      case AssetCategory.furniture:
        return 'Furniture';
      case AssetCategory.computers:
        return 'Computers';
      case AssetCategory.office_equipment:
        return 'Office Equipment';
    }
  }

  String _getDepreciationMethodDisplayName(DepreciationMethod method) {
    switch (method) {
      case DepreciationMethod.straight_line:
        return 'Straight Line';
      case DepreciationMethod.declining_balance:
        return 'Declining Balance';
      case DepreciationMethod.units_of_production:
        return 'Units of Production';
      case DepreciationMethod.none:
        return 'No Depreciation';
    }
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _descriptionController.dispose();
    _acquisitionCostController.dispose();
    _usefulLifeController.dispose();
    _salvageValueController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    _insuranceValueController.dispose();
    _supplierNameController.dispose();         // New
    _purchaseOrderNumberController.dispose();   // New
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/warehouse_model.dart';
import '../../../../providers/warehouse_provider.dart';

class WarehouseFormView extends ConsumerStatefulWidget {
  final Warehouse? warehouse;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const WarehouseFormView({
    super.key,
    this.warehouse,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<WarehouseFormView> createState() => _WarehouseFormViewState();
}

class _WarehouseFormViewState extends ConsumerState<WarehouseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _warehouseCodeController = TextEditingController();
  final _warehouseNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Contact Controllers
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _faxController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Capacity Controllers
  final _totalAreaController = TextEditingController();
  final _usableAreaController = TextEditingController();
  final _storageCapacityController = TextEditingController();
  final _palletPositionsController = TextEditingController();

  WarehouseStatus _status = WarehouseStatus.OPERATIONAL;
  LayoutType _layoutType = LayoutType.SINGLE_STORY;
  int _aisles = 0;
  int _racks = 0;
  int _loadingBays = 0;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.warehouse != null;
    if (_isEditing) {
      _loadWarehouseData();
    }
  }

  void _loadWarehouseData() {
    final warehouse = widget.warehouse;
    if (warehouse != null) {
      _warehouseCodeController.text = warehouse.warehouseCode;
      _warehouseNameController.text = warehouse.warehouseName;
      _descriptionController.text = warehouse.description;

      // Address
      _addressLine1Controller.text = warehouse.address.addressLine1;
      _addressLine2Controller.text = warehouse.address.addressLine2 ?? '';
      _cityController.text = warehouse.address.city;
      _stateController.text = warehouse.address.state;
      _postalCodeController.text = warehouse.address.postalCode;
      _countryController.text = warehouse.address.country;

      // Contact
      _phoneController.text = warehouse.contactInformation.phone;
      _emailController.text = warehouse.contactInformation.email;
      _faxController.text = warehouse.contactInformation.fax ?? '';
      _emergencyContactController.text =
          warehouse.contactInformation.emergencyContact;

      // Capacity
      _totalAreaController.text = warehouse.capacity.totalArea.toString();
      _usableAreaController.text = warehouse.capacity.usableArea.toString();
      _storageCapacityController.text =
          warehouse.capacity.storageCapacity.toString();
      _palletPositionsController.text =
          warehouse.capacity.palletPositions.toString();

      // Layout
      _layoutType = warehouse.layout.layoutType;
      _aisles = warehouse.layout.aisles;
      _racks = warehouse.layout.racks;
      _loadingBays = warehouse.layout.loadingBays;

      _status = warehouse.status;
    }
  }

  Future<void> _saveWarehouse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final warehouse = Warehouse(
        id: widget.warehouse?.id ?? '',
        warehouseCode: _warehouseCodeController.text.trim(),
        warehouseName: _warehouseNameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: WarehouseAddress(
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim().isEmpty
              ? null
              : _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
        ),
        coordinates: WarehouseCoordinates(latitude: 0.0, longitude: 0.0),
        contactInformation: WarehouseContact(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          fax: _faxController.text.trim().isEmpty
              ? null
              : _faxController.text.trim(),
          emergencyContact: _emergencyContactController.text.trim(),
        ),
        capacity: WarehouseCapacity(
          totalArea: double.tryParse(_totalAreaController.text) ?? 0,
          usableArea: double.tryParse(_usableAreaController.text) ?? 0,
          storageCapacity:
              double.tryParse(_storageCapacityController.text) ?? 0,
          palletPositions: int.tryParse(_palletPositionsController.text) ?? 0,
          currentUtilization: 0,
        ),
        layout: WarehouseLayout(
          layoutType: _layoutType,
          aisles: _aisles,
          racks: _racks,
          loadingBays: _loadingBays,
          layoutMap: null,
        ),
        zones: widget.warehouse?.zones ?? [],
        storageTypes: widget.warehouse?.storageTypes ?? [],
        operatingHours: widget.warehouse?.operatingHours ??
            OperatingHours(
              monday: TimeSlot(
                  open: true, openingTime: '08:00', closingTime: '17:00'),
              tuesday: TimeSlot(
                  open: true, openingTime: '08:00', closingTime: '17:00'),
              wednesday: TimeSlot(
                  open: true, openingTime: '08:00', closingTime: '17:00'),
              thursday: TimeSlot(
                  open: true, openingTime: '08:00', closingTime: '17:00'),
              friday: TimeSlot(
                  open: true, openingTime: '08:00', closingTime: '17:00'),
              saturday: TimeSlot(open: false),
              sunday: TimeSlot(open: false),
              holidays: [],
            ),
        handlingEquipment: widget.warehouse?.handlingEquipment ?? [],
        security: widget.warehouse?.security ??
            SecurityMeasures(
              accessControl: [],
              surveillance: [],
              alarmSystems: [],
              fireProtection: [],
              securityPersonnel: 0,
            ),
        warehouseManager: widget.warehouse?.warehouseManager ?? '',
        staff: widget.warehouse?.staff ?? [],
        performance: widget.warehouse?.performance ??
            WarehousePerformance(
              orderAccuracy: 0,
              pickingEfficiency: 0,
              shippingAccuracy: 0,
              damageRate: 0,
              turnaroundTime: 0,
            ),
        utilization: widget.warehouse?.utilization ??
            UtilizationMetrics(
              spaceUtilization: 0,
              equipmentUtilization: 0,
              laborUtilization: 0,
              throughput: 0,
            ),
        services: widget.warehouse?.services ?? [],
        valueAddedServices: widget.warehouse?.valueAddedServices ?? [],
        certifications: widget.warehouse?.certifications ?? [],
        compliance: widget.warehouse?.compliance ??
            ComplianceStatus(
              safetyCompliance: ComplianceLevel.FULL_COMPLIANCE,
              environmentalCompliance: ComplianceLevel.FULL_COMPLIANCE,
              qualityCompliance: ComplianceLevel.FULL_COMPLIANCE,
              lastAuditDate: DateTime.now(),
              nextAuditDate: DateTime.now().add(const Duration(days: 365)),
            ),
        status: _status,
        isActive: true,
        createdAt: widget.warehouse?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await ref
            .read(warehouseProvider.notifier)
            .updateWarehouse(widget.warehouse!.id, warehouse);
        _showSuccessSnackbar('Warehouse updated successfully');
      } else {
        await ref.read(warehouseProvider.notifier).createWarehouse(warehouse);
        _showSuccessSnackbar('Warehouse created successfully');
      }

      widget.onSave();
    } catch (e) {
      _showErrorSnackbar('Failed to save warehouse: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Basic Information
            _buildBasicInfoSection(theme),
            const SizedBox(height: 24),

            // Address Information
            _buildAddressSection(theme),
            const SizedBox(height: 24),

            // Contact Information
            _buildContactSection(theme),
            const SizedBox(height: 24),

            // Capacity Information
            _buildCapacitySection(theme),
            const SizedBox(height: 24),

            // Layout Information
            _buildLayoutSection(theme),
            const SizedBox(height: 24),

            // Status
            _buildStatusSection(theme),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
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
              controller: _warehouseCodeController,
              decoration: const InputDecoration(
                labelText: 'Warehouse Code*',
                hintText: 'e.g., WH-001',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter warehouse code';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _warehouseNameController,
              decoration: const InputDecoration(
                labelText: 'Warehouse Name*',
                hintText: 'e.g., Nairobi Main Warehouse',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter warehouse name';
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
                hintText: 'Describe the warehouse purpose and features...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1*',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Region*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter postal code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter country';
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

  Widget _buildContactSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number*',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email*',
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _faxController,
              decoration: const InputDecoration(
                labelText: 'Fax',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact*',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter emergency contact';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacity Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Total Area (m²)*',
                      suffixText: 'm²',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter total area';
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
                    controller: _usableAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Usable Area (m²)*',
                      suffixText: 'm²',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter usable area';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _storageCapacityController,
                    decoration: const InputDecoration(
                      labelText: 'Storage Capacity (m³)*',
                      suffixText: 'm³',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter storage capacity';
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
                    controller: _palletPositionsController,
                    decoration: const InputDecoration(
                      labelText: 'Pallet Positions*',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pallet positions';
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
      ),
    );
  }

  Widget _buildLayoutSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Layout Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LayoutType>(
              value: _layoutType,
              decoration: const InputDecoration(
                labelText: 'Layout Type*',
              ),
              items: LayoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatLayoutType(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() => _layoutType = type);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _aisles.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Number of Aisles',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _aisles = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _racks.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Number of Racks',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _racks = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _loadingBays.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Loading Bays',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _loadingBays = int.tryParse(value) ?? 0;
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

  Widget _buildStatusSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WarehouseStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Warehouse Status*',
              ),
              items: WarehouseStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_formatStatus(status)),
                );
              }).toList(),
              onChanged: (status) {
                if (status != null) {
                  setState(() => _status = status);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveWarehouse,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text(_isEditing ? 'Update Warehouse' : 'Create Warehouse'),
          ),
        ),
      ],
    );
  }

  String _formatLayoutType(LayoutType type) {
    switch (type) {
      case LayoutType.SINGLE_STORY:
        return 'Single Story';
      case LayoutType.MULTI_STORY:
        return 'Multi Story';
      case LayoutType.RACKED:
        return 'Racked';
      case LayoutType.BULK_STORAGE:
        return 'Bulk Storage';
      case LayoutType.AUTOMATED:
        return 'Automated';
    }
  }

  String _formatStatus(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL:
        return 'Operational';
      case WarehouseStatus.UNDER_MAINTENANCE:
        return 'Under Maintenance';
      case WarehouseStatus.CLOSED:
        return 'Closed';
      case WarehouseStatus.UNDER_CONSTRUCTION:
        return 'Under Construction';
    }
  }

  @override
  void dispose() {
    _warehouseCodeController.dispose();
    _warehouseNameController.dispose();
    _descriptionController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _faxController.dispose();
    _emergencyContactController.dispose();
    _totalAreaController.dispose();
    _usableAreaController.dispose();
    _storageCapacityController.dispose();
    _palletPositionsController.dispose();
    super.dispose();
  }
}

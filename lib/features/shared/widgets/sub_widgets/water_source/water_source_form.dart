import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/water_source_model.dart';
import '../../../providers/water_source_provider.dart';
import '../../../utils/water_sources/water_source_constants.dart';

class WaterSourceForm extends ConsumerStatefulWidget {
  final WaterSource? initialData;
  final bool isEditing;
  final VoidCallback? onSuccess;

  const WaterSourceForm({
    Key? key,
    this.initialData,
    this.isEditing = false,
    this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<WaterSourceForm> createState() => _WaterSourceFormState();
}

class _WaterSourceFormState extends ConsumerState<WaterSourceForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false, false];

  // Controllers for basic info
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _catchmentAreaController = TextEditingController();
  final _elevationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Controllers for capacity
  final _dailyYieldController = TextEditingController();
  final _safeYieldController = TextEditingController();
  final _currentUsageController = TextEditingController();
  final _droughtReserveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialData != null) {
      _initializeFormData(widget.initialData!);
    }
  }

  void _initializeFormData(WaterSource data) {
    _nameController.text = data.name;
    _addressController.text = data.location.address;
    _catchmentAreaController.text = data.location.catchmentArea;
    _elevationController.text = data.location.elevation.toString();
    _latitudeController.text = data.location.coordinates.latitude.toString();
    _longitudeController.text = data.location.coordinates.longitude.toString();

    _dailyYieldController.text = data.capacity.dailyYield.toString();
    _safeYieldController.text = data.capacity.safeYield.toString();
    _currentUsageController.text = data.capacity.currentUsage.toString();
    _droughtReserveController.text = data.capacity.droughtReserve.toString();

    _formData['type'] = data.type.value;
    _formData['status'] = data.status.value;
    _formData['qualityGrade'] = data.quality.qualityGrade.value;
    _formData['phLevel'] = data.quality.phLevel.toString();
    _formData['turbidity'] = data.quality.turbidity.toString();
    _formData['treatmentRequired'] = data.infrastructure.treatmentRequired;
    _formData['pumps'] = data.infrastructure.pumps.toString();
    _formData['storageCapacity'] =
        data.infrastructure.storageCapacity.toString();
    _formData['transmissionLines'] =
        data.infrastructure.transmissionLines.toString();
    _formData['powerSupply'] = data.infrastructure.powerSupply;
    _formData['monitoringFrequency'] = data.monitoring.monitoringFrequency;
    _formData['parameters'] = data.monitoring.parameters;
    _formData['contaminationRisks'] = data.quality.contaminationRisks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? 'Edit Water Source' : 'New Water Source'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Theme.of(context).primaryColor,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _goToNextStep,
          onStepCancel: _goToPreviousStep,
          onStepTapped: (step) {
            if (_currentStep > step || _stepCompleted[step]) {
              setState(() => _currentStep = step);
            }
          },
          steps: [
            _buildBasicInfoStep(),
            _buildCapacityStep(),
            _buildQualityStep(),
            _buildInfrastructureStep(),
          ],
        ),
      ),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      title: const Text('Basic Information'),
      subtitle: const Text('Name, location, and type'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Water Source Name *',
                hintText: 'e.g., Main Borehole - Nakuru',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _formData['name'] = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WaterSourceType>(
              decoration: const InputDecoration(
                labelText: 'Source Type *',
              ),
              value: _formData['type'] != null
                  ? WaterSourceType.values.firstWhere(
                      (e) => e.value == _formData['type'],
                      orElse: () => WaterSourceType.WELL,
                    )
                  : WaterSourceType.WELL,
              items: WaterSourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _formData['type'] = value.value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SourceStatus>(
              decoration: const InputDecoration(
                labelText: 'Status *',
              ),
              value: _formData['status'] != null
                  ? SourceStatus.values.firstWhere(
                      (e) => e.value == _formData['status'],
                      orElse: () => SourceStatus.OPERATIONAL,
                    )
                  : SourceStatus.OPERATIONAL,
              items: SourceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _formData['status'] = value.value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Location Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                hintText: 'Full physical address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onSaved: (value) => _formData['address'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _catchmentAreaController,
              decoration: const InputDecoration(
                labelText: 'Catchment Area *',
                hintText: 'e.g., Lake Nakuru Basin',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter catchment area';
                }
                return null;
              },
              onSaved: (value) => _formData['catchmentArea'] = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      hintText: 'e.g., -0.3031',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter latitude';
                      }
                      final double? lat = double.tryParse(value);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Enter valid latitude (-90 to 90)';
                      }
                      return null;
                    },
                    onSaved: (value) => _formData['latitude'] = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      hintText: 'e.g., 36.0800',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter longitude';
                      }
                      final double? lng = double.tryParse(value);
                      if (lng == null || lng < -180 || lng > 180) {
                        return 'Enter valid longitude (-180 to 180)';
                      }
                      return null;
                    },
                    onSaved: (value) => _formData['longitude'] = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _elevationController,
              decoration: const InputDecoration(
                labelText: 'Elevation (meters) *',
                hintText: 'e.g., 1800',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter elevation';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter valid number';
                }
                return null;
              },
              onSaved: (value) => _formData['elevation'] = value,
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _stepCompleted[0] ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildCapacityStep() {
    return Step(
      title: const Text('Capacity Information'),
      subtitle: const Text('Yield, usage, and reserves'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All capacities are in cubic meters per day (m³/day)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dailyYieldController,
            decoration: const InputDecoration(
              labelText: 'Daily Yield (m³/day) *',
              hintText: 'e.g., 5000',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter daily yield';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
            onSaved: (value) => _formData['dailyYield'] = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _safeYieldController,
            decoration: const InputDecoration(
              labelText: 'Safe Yield (m³/day) *',
              hintText: 'Sustainable extraction rate',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter safe yield';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
            onSaved: (value) => _formData['safeYield'] = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentUsageController,
            decoration: const InputDecoration(
              labelText: 'Current Usage (m³/day) *',
              hintText: 'Current daily consumption',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current usage';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
            onSaved: (value) => _formData['currentUsage'] = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _droughtReserveController,
            decoration: const InputDecoration(
              labelText: 'Drought Reserve (m³) *',
              hintText: 'Emergency reserve capacity',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter drought reserve';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
            onSaved: (value) => _formData['droughtReserve'] = value,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _stepCompleted[1] ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildQualityStep() {
    return Step(
      title: const Text('Water Quality'),
      subtitle: const Text('Quality metrics and risks'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<QualityGrade>(
            decoration: const InputDecoration(
              labelText: 'Quality Grade *',
            ),
            value: _formData['qualityGrade'] != null
                ? QualityGrade.values.firstWhere(
                    (e) => e.value == _formData['qualityGrade'],
                    orElse: () => QualityGrade.GOOD,
                  )
                : QualityGrade.GOOD,
            items: QualityGrade.values.map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(grade.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _formData['qualityGrade'] = value.value);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _formData['phLevel'] ?? '7.0',
                  decoration: const InputDecoration(
                    labelText: 'pH Level *',
                    hintText: '6.5 - 8.5 ideal',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pH level';
                    }
                    final double? ph = double.tryParse(value);
                    if (ph == null || ph < 0 || ph > 14) {
                      return 'Enter valid pH (0-14)';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['phLevel'] = value,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _formData['turbidity'] ?? '1.0',
                  decoration: const InputDecoration(
                    labelText: 'Turbidity (NTU) *',
                    hintText: 'Lower is better',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter turbidity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['turbidity'] = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Treatment Required'),
            value: _formData['treatmentRequired'] ?? false,
            onChanged: (value) {
              setState(() => _formData['treatmentRequired'] = value);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Contamination Risks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WaterSourceConstants.contaminationRisks.map((risk) {
              final isSelected =
                  (_formData['contaminationRisks'] as List?)?.contains(risk) ??
                      false;
              return FilterChip(
                label: Text(risk),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final risks = List<String>.from(
                        _formData['contaminationRisks'] ?? []);
                    if (selected) {
                      risks.add(risk);
                    } else {
                      risks.remove(risk);
                    }
                    _formData['contaminationRisks'] = risks;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _stepCompleted[2] ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildInfrastructureStep() {
    return Step(
      title: const Text('Infrastructure'),
      subtitle: const Text('Equipment and monitoring'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _formData['pumps'] ?? '1',
                  decoration: const InputDecoration(
                    labelText: 'Number of Pumps *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of pumps';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['pumps'] = value,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _formData['storageCapacity'] ?? '1000',
                  decoration: const InputDecoration(
                    labelText: 'Storage Capacity (m³) *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter storage capacity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['storageCapacity'] = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _formData['transmissionLines'] ?? '5.0',
            decoration: const InputDecoration(
              labelText: 'Transmission Lines (km) *',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter transmission line length';
              }
              if (double.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
            onSaved: (value) => _formData['transmissionLines'] = value,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Power Supply *',
            ),
            value: _formData['powerSupply'] ?? 'grid',
            items: WaterSourceConstants.powerSupplyTypes.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _formData['powerSupply'] = value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Monitoring Frequency *',
            ),
            value: _formData['monitoringFrequency'] ?? 'monthly',
            items:
                WaterSourceConstants.monitoringFrequencies.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _formData['monitoringFrequency'] = value);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Monitoring Parameters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WaterSourceConstants.monitoringParameters.map((param) {
              final isSelected =
                  (_formData['parameters'] as List?)?.contains(param) ?? false;
              return FilterChip(
                label: Text(param),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final params =
                        List<String>.from(_formData['parameters'] ?? []);
                    if (selected) {
                      params.add(param);
                    } else {
                      params.remove(param);
                    }
                    _formData['parameters'] = params;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _stepCompleted[3] ? StepState.complete : StepState.indexed,
    );
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (!_validateBasicInfo()) return;
      _saveBasicInfo();
      _stepCompleted[0] = true;
    } else if (_currentStep == 1) {
      if (!_validateCapacity()) return;
      _saveCapacity();
      _stepCompleted[1] = true;
    } else if (_currentStep == 2) {
      if (!_validateQuality()) return;
      _saveQuality();
      _stepCompleted[2] = true;
    } else if (_currentStep == 3) {
      if (!_validateInfrastructure()) return;
      _saveInfrastructure();
      _stepCompleted[3] = true;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateBasicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  void _saveBasicInfo() {
    _formKey.currentState?.save();
  }

  bool _validateCapacity() {
    // Add validation logic for capacity step
    return true;
  }

  void _saveCapacity() {
    _formData['dailyYield'] = _dailyYieldController.text;
    _formData['safeYield'] = _safeYieldController.text;
    _formData['currentUsage'] = _currentUsageController.text;
    _formData['droughtReserve'] = _droughtReserveController.text;
  }

  bool _validateQuality() {
    // Add validation logic for quality step
    return true;
  }

  void _saveQuality() {
    // Quality data is already saved in formData through onChanged
  }

  bool _validateInfrastructure() {
    // Add validation logic for infrastructure step
    return true;
  }

  void _saveInfrastructure() {
    // Infrastructure data is already saved in formData through onChanged
  }

  Future<void> _submitForm() async {
    try {
      // Prepare final data
      final data = {
        'name': _nameController.text,
        'type': _formData['type'],
        'status': _formData['status'],
        'location': {
          'coordinates': {
            'latitude': double.parse(_latitudeController.text),
            'longitude': double.parse(_longitudeController.text),
          },
          'address': _addressController.text,
          'catchmentArea': _catchmentAreaController.text,
          'elevation': double.parse(_elevationController.text),
        },
        'capacity': {
          'dailyYield': double.parse(_dailyYieldController.text),
          'safeYield': double.parse(_safeYieldController.text),
          'currentUsage': double.parse(_currentUsageController.text),
          'utilizationRate': 0.0, // Will be calculated by backend
          'droughtReserve': double.parse(_droughtReserveController.text),
        },
        'quality': {
          'qualityGrade': _formData['qualityGrade'],
          'phLevel': double.parse(_formData['phLevel'] ?? '7.0'),
          'turbidity': double.parse(_formData['turbidity'] ?? '1.0'),
          'contaminationRisks': _formData['contaminationRisks'] ?? [],
          'treatmentRequired': _formData['treatmentRequired'] ?? false,
          'lastTestDate': DateTime.now().toIso8601String(),
        },
        'infrastructure': {
          'pumps': int.parse(_formData['pumps'] ?? '1'),
          'treatmentRequired': _formData['treatmentRequired'] ?? false,
          'storageCapacity':
              double.parse(_formData['storageCapacity'] ?? '1000'),
          'transmissionLines':
              double.parse(_formData['transmissionLines'] ?? '5.0'),
          'powerSupply': _formData['powerSupply'] ?? 'grid',
        },
        'monitoring': {
          'monitoringFrequency': _formData['monitoringFrequency'] ?? 'monthly',
          'parameters': _formData['parameters'] ?? [],
          'lastInspection': DateTime.now().toIso8601String(),
          'nextInspection':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'alerts': [],
        },
      };

      // Call provider to create/update
      final provider = ref.read(waterSourceProvider.notifier);

      if (widget.isEditing && widget.initialData != null) {
        await provider.updateWaterSource(widget.initialData!.id, data);
      } else {
        await provider.createWaterSource(data);
      }

      // Success
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _catchmentAreaController.dispose();
    _elevationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _dailyYieldController.dispose();
    _safeYieldController.dispose();
    _currentUsageController.dispose();
    _droughtReserveController.dispose();
    super.dispose();
  }
}

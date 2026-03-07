import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/service_area_model.dart';
import '../../../providers/service_area_provider.dart';

class ServiceAreaForm extends ConsumerStatefulWidget {
  final ServiceArea? initialData;
  final VoidCallback onSuccess;

  const ServiceAreaForm({
    super.key,
    this.initialData,
    required this.onSuccess,
  });

  @override
  _ServiceAreaFormState createState() => _ServiceAreaFormState();
}

class _ServiceAreaFormState extends ConsumerState<ServiceAreaForm> {
  final _formKey = GlobalKey<FormState>();
  late ServiceArea _serviceArea;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serviceArea = widget.initialData ??
        ServiceArea(
          id: '',
          name: '',
          description: '',
          type: AreaType.urban,
          status: ServiceStatus.active,
          coverage: CoverageInfo(
            totalArea: 0,
            waterCoverage: 0,
            sewerageCoverage: 0,
            connectionRate: 0,
            lastUpdated: DateTime.now(),
          ),
          services: [ServiceType.water_supply],
          population: 0,
          households: 0,
          waterSources: [],
          treatmentPlants: [],
          infrastructure: InfrastructureInfo(
            waterMains: 0,
            sewerMains: 0,
            reservoirs: 0,
            pumpingStations: 0,
            treatmentPlants: 0,
            lastRehabilitation: DateTime.now(),
          ),
          contact: ContactInfo(
            officeAddress: '',
            phone: '',
            email: '',
            manager: '',
            emergencyContact: '',
          ),
          createdBy: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = ref.read(serviceAreaProvider.notifier);
    final success = widget.initialData == null
        ? await provider.createServiceArea(_serviceArea)
        : await provider.updateServiceArea(_serviceArea.id, _serviceArea);

    setState(() => _isLoading = false);

    if (success && mounted) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter service area name',
                  prefixIcon: Icon(Icons.location_city),
                ),
                initialValue: _serviceArea.name,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
                onChanged: (value) =>
                    _serviceArea = _serviceArea.copyWith(name: value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter service area description',
                  prefixIcon: Icon(Icons.description),
                ),
                initialValue: _serviceArea.description,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Description is required' : null,
                onChanged: (value) =>
                    _serviceArea = _serviceArea.copyWith(description: value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<AreaType>(
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _serviceArea.type,
                      items: AreaType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(type.icon,
                                        size: 20, color: type.color),
                                    const SizedBox(width: 8),
                                    Text(type.displayName),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(type: value);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<ServiceStatus>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info),
                      ),
                      value: _serviceArea.status,
                      items: ServiceStatus.values
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(status.icon,
                                        size: 20, color: status.color),
                                    const SizedBox(width: 8),
                                    Text(status.displayName),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(status: value);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Coverage Information Section
              _buildSectionHeader('Coverage Information'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Total Area (km²)',
                        prefixIcon: Icon(Icons.square_foot),
                      ),
                      initialValue: _serviceArea.coverage.totalArea.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = double.tryParse(value ?? '');
                        return num == null || num <= 0
                            ? 'Enter a valid area'
                            : null;
                      },
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              coverage: _serviceArea.coverage.copyWith(
                                totalArea: num,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Water Coverage (%)',
                        prefixIcon: Icon(Icons.water_drop),
                        suffixText: '%',
                      ),
                      initialValue:
                          _serviceArea.coverage.waterCoverage.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = double.tryParse(value ?? '');
                        return num == null || num < 0 || num > 100
                            ? 'Enter 0-100'
                            : null;
                      },
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              coverage: _serviceArea.coverage.copyWith(
                                waterCoverage: num,
                              ),
                            );
                          });
                        }
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
                      decoration: const InputDecoration(
                        labelText: 'Sewerage Coverage (%)',
                        prefixIcon: Icon(Icons.plumbing),
                        suffixText: '%',
                      ),
                      initialValue:
                          _serviceArea.coverage.sewerageCoverage.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = double.tryParse(value ?? '');
                        return num == null || num < 0 || num > 100
                            ? 'Enter 0-100'
                            : null;
                      },
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              coverage: _serviceArea.coverage.copyWith(
                                sewerageCoverage: num,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Connection Rate (%)',
                        prefixIcon: Icon(Icons.link),
                        suffixText: '%',
                      ),
                      initialValue:
                          _serviceArea.coverage.connectionRate.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = double.tryParse(value ?? '');
                        return num == null || num < 0 || num > 100
                            ? 'Enter 0-100'
                            : null;
                      },
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              coverage: _serviceArea.coverage.copyWith(
                                connectionRate: num,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Population & Infrastructure Section
              _buildSectionHeader('Population & Infrastructure'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Population',
                        prefixIcon: Icon(Icons.people),
                      ),
                      initialValue: _serviceArea.population.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = int.tryParse(value ?? '');
                        return num == null || num < 0
                            ? 'Enter valid number'
                            : null;
                      },
                      onChanged: (value) {
                        final num = int.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea =
                                _serviceArea.copyWith(population: num);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Households',
                        prefixIcon: Icon(Icons.home),
                      ),
                      initialValue: _serviceArea.households.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final num = int.tryParse(value ?? '');
                        return num == null || num < 0
                            ? 'Enter valid number'
                            : null;
                      },
                      onChanged: (value) {
                        final num = int.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea =
                                _serviceArea.copyWith(households: num);
                          });
                        }
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
                      decoration: const InputDecoration(
                        labelText: 'Water Mains (km)',
                        prefixIcon: Icon(Icons.plumbing),
                      ),
                      initialValue:
                          _serviceArea.infrastructure.waterMains.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              infrastructure:
                                  _serviceArea.infrastructure.copyWith(
                                waterMains: num,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Sewer Mains (km)',
                        prefixIcon: Icon(Icons.plumbing),
                      ),
                      initialValue:
                          _serviceArea.infrastructure.sewerMains.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final num = double.tryParse(value);
                        if (num != null) {
                          setState(() {
                            _serviceArea = _serviceArea.copyWith(
                              infrastructure:
                                  _serviceArea.infrastructure.copyWith(
                                sewerMains: num,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Office Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                initialValue: _serviceArea.contact.officeAddress,
                onChanged: (value) {
                  setState(() {
                    _serviceArea = _serviceArea.copyWith(
                      contact:
                          _serviceArea.contact.copyWith(officeAddress: value),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      initialValue: _serviceArea.contact.phone,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _serviceArea = _serviceArea.copyWith(
                            contact:
                                _serviceArea.contact.copyWith(phone: value),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      initialValue: _serviceArea.contact.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _serviceArea = _serviceArea.copyWith(
                            contact:
                                _serviceArea.contact.copyWith(email: value),
                          );
                        });
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
                      decoration: const InputDecoration(
                        labelText: 'Manager',
                        prefixIcon: Icon(Icons.person),
                      ),
                      initialValue: _serviceArea.contact.manager,
                      onChanged: (value) {
                        setState(() {
                          _serviceArea = _serviceArea.copyWith(
                            contact:
                                _serviceArea.contact.copyWith(manager: value),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact',
                        prefixIcon: Icon(Icons.emergency),
                      ),
                      initialValue: _serviceArea.contact.emergencyContact,
                      onChanged: (value) {
                        setState(() {
                          _serviceArea = _serviceArea.copyWith(
                            contact: _serviceArea.contact
                                .copyWith(emergencyContact: value),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Services Section
              _buildSectionHeader('Services'),
              Wrap(
                spacing: 8,
                children: ServiceType.values.map((service) {
                  final isSelected = _serviceArea.services.contains(service);
                  return FilterChip(
                    label: Text(service.displayName),
                    avatar: Icon(service.icon, size: 16),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        final services =
                            List<ServiceType>.from(_serviceArea.services);
                        if (selected) {
                          services.add(service);
                        } else {
                          services.remove(service);
                        }
                        _serviceArea =
                            _serviceArea.copyWith(services: services);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.initialData == null
                              ? 'Create Service Area'
                              : 'Update Service Area',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}

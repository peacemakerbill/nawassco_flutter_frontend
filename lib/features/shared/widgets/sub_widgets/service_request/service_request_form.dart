import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/service_request_model.dart';
import '../../../providers/service_request_provider.dart';

class ServiceRequestForm extends ConsumerStatefulWidget {
  final ServiceRequest? initialData;
  final VoidCallback? onSuccess;

  const ServiceRequestForm({
    super.key,
    this.initialData,
    this.onSuccess,
  });

  @override
  ConsumerState<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends ConsumerState<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  // Sample data for dropdowns
  final List<Map<String, String>> _services = [
    {'id': '1', 'name': 'New Water Connection', 'code': 'NWC', 'category': 'waterSupply', 'type': 'newConnection'},
    {'id': '2', 'name': 'Leak Repair', 'code': 'LRP', 'category': 'waterSupply', 'type': 'leakRepair'},
    {'id': '3', 'name': 'Water Quality Testing', 'code': 'WQT', 'category': 'laboratory', 'type': 'qualityTesting'},
    {'id': '4', 'name': 'Sewer Connection', 'code': 'SWC', 'category': 'sewerage', 'type': 'sewerConnection'},
    {'id': '5', 'name': 'Blockage Clearance', 'code': 'BLC', 'category': 'sewerage', 'type': 'blockageClearance'},
    {'id': '6', 'name': 'Meter Reading', 'code': 'MTR', 'category': 'waterSupply', 'type': 'meterReading'},
  ];

  final List<String> _customerTypes = CustomerType.values.map((e) => e.name).toList();
  final List<String> _propertyTypes = PropertyType.values.map((e) => e.name).toList();
  final List<String> _priorities = PriorityLevel.values.map((e) => e.name).toList();

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData?.toJson() ?? {
      'service': '',
      'serviceName': '',
      'serviceCode': '',
      'serviceCategory': '',
      'serviceType': '',
      'customerName': '',
      'customerEmail': '',
      'customerPhone': '',
      'customerAddress': '',
      'customerType': 'residential',
      'propertyType': 'house',
      'description': '',
      'priority': 'medium',
      'estimatedCost': '0',
      'department': 'Field Operations',
      'location': {
        'address': '',
        'zone': '',
        'subzone': '',
        'accessibility': 'accessible',
        'coordinates': {
          'latitude': 0.0,
          'longitude': 0.0,
        },
      },
    };
  }

  void _onServiceChanged(String? serviceId) {
    if (serviceId != null) {
      final service = _services.firstWhere((s) => s['id'] == serviceId);
      setState(() {
        _formData['service'] = serviceId;
        _formData['serviceName'] = service['name'];
        _formData['serviceCode'] = service['code'];
        _formData['serviceCategory'] = service['category'];
        _formData['serviceType'] = service['type'];
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = ref.read(serviceRequestProvider.notifier);

      if (widget.initialData == null) {
        // Create new request
        await provider.createServiceRequest(_formData);
      } else {
        // Update existing request
        await provider.updateServiceRequest(
          widget.initialData!.id,
          _formData,
        );
      }

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.initialData != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Edit Service Request' : 'New Service Request',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Service Selection
            DropdownButtonFormField<String>(
              value: _formData['service'],
              decoration: const InputDecoration(
                labelText: 'Service Type',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
              items: _services.map((service) {
                return DropdownMenuItem(
                  value: service['id'],
                  child: Text(service['name']!),
                );
              }).toList(),
              onChanged: _onServiceChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a service';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Customer Information Section
            _buildSectionHeader('Customer Information'),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _formData['customerName'],
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _formData['customerName'] = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _formData['customerEmail'],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _formData['customerEmail'] = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _formData['customerPhone'],
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _formData['customerPhone'] = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _formData['customerAddress'],
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSaved: (value) => _formData['customerAddress'] = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _formData['customerType'],
                    decoration: const InputDecoration(
                      labelText: 'Customer Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _customerTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ').toTitleCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _formData['customerType'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _formData['propertyType'],
                    decoration: const InputDecoration(
                      labelText: 'Property Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _propertyTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ').toTitleCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _formData['propertyType'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Location Information Section
            _buildSectionHeader('Location Details'),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _formData['location']['address'],
              decoration: const InputDecoration(
                labelText: 'Service Address',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSaved: (value) => _formData['location']['address'] = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _formData['location']['zone'],
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _formData['location']['zone'] = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter zone';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _formData['location']['subzone'],
                    decoration: const InputDecoration(
                      labelText: 'Subzone',
                      prefixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _formData['location']['subzone'] = value ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _formData['location']['accessibility'],
              decoration: const InputDecoration(
                labelText: 'Accessibility Notes',
                prefixIcon: Icon(Icons.accessible),
                border: OutlineInputBorder(),
                helperText: 'e.g., Gate code, Parking instructions, etc.',
              ),
              maxLines: 2,
              onSaved: (value) => _formData['location']['accessibility'] = value ?? 'accessible',
            ),
            const SizedBox(height: 20),

            // Request Details Section
            _buildSectionHeader('Request Details'),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _formData['description'],
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              onSaved: (value) => _formData['description'] = value ?? '',
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
                  child: DropdownButtonFormField<String>(
                    value: _formData['priority'],
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: _priorities.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Icon(
                              _getPriorityIcon(PriorityLevel.values.firstWhere((e) => e.name == priority)),
                              size: 16,
                              color: _getPriorityColor(PriorityLevel.values.firstWhere((e) => e.name == priority)),
                            ),
                            const SizedBox(width: 8),
                            Text(priority.replaceAll('_', ' ').toTitleCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _formData['priority'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _formData['estimatedCost'],
                    decoration: const InputDecoration(
                      labelText: 'Estimated Cost (KES)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _formData['estimatedCost'] = value ?? '0',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter estimated cost';
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

            TextFormField(
              initialValue: _formData['department'],
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                helperText: 'e.g., Field Operations, Technical, etc.',
              ),
              onSaved: (value) => _formData['department'] = value ?? 'Field Operations',
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditMode ? 'Update Request' : 'Submit Request',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
        return Colors.red[900]!;
      case PriorityLevel.urgent:
        return Colors.red;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.medium:
        return Colors.blue;
      case PriorityLevel.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.emergency:
      case PriorityLevel.urgent:
        return Icons.warning;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.medium:
        return Icons.horizontal_rule;
      case PriorityLevel.low:
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
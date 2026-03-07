import 'package:flutter/material.dart';
import '../../../models/water_meter.model.dart';

class WaterMeterFilterWidget extends StatefulWidget {
  final Function(WaterMeterFilters) onFiltersChanged;
  final VoidCallback onClear;

  const WaterMeterFilterWidget({
    super.key,
    required this.onFiltersChanged,
    required this.onClear,
  });

  @override
  State<WaterMeterFilterWidget> createState() => _WaterMeterFilterWidgetState();
}

class _WaterMeterFilterWidgetState extends State<WaterMeterFilterWidget> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _wardController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();

  final List<MeterStatus> _selectedStatuses = [];
  final List<MeterType> _selectedTypes = [];
  final List<MeterTechnology> _selectedTechnologies = [];
  final List<ConnectivityStatus> _selectedConnectivity = [];
  final List<NakuruServiceRegion> _selectedRegions = [];

  String? _selectedAccessibility;
  String? _selectedInstallationType;
  DateTime? _installedFrom;
  DateTime? _installedTo;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    // Load any previously selected filters
    // This could be from shared preferences or state
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    _serialNumberController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _wardController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = WaterMeterFilters(
      meterNumber: _meterNumberController.text.isNotEmpty
          ? _meterNumberController.text
          : null,
      serialNumber: _serialNumberController.text.isNotEmpty
          ? _serialNumberController.text
          : null,
      customerName: _customerNameController.text.isNotEmpty
          ? _customerNameController.text
          : null,
      customerEmail: _customerEmailController.text.isNotEmpty
          ? _customerEmailController.text
          : null,
      customerPhone: _customerPhoneController.text.isNotEmpty
          ? _customerPhoneController.text
          : null,
      serviceRegions: _selectedRegions.isNotEmpty ? _selectedRegions : null,
      ward: _wardController.text.isNotEmpty ? _wardController.text : null,
      statuses: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
      types: _selectedTypes.isNotEmpty ? _selectedTypes : null,
      technologies: _selectedTechnologies.isNotEmpty ? _selectedTechnologies : null,
      connectivityStatuses: _selectedConnectivity.isNotEmpty ? _selectedConnectivity : null,
      installedFrom: _installedFrom,
      installedTo: _installedTo,
      manufacturer: _manufacturerController.text.isNotEmpty
          ? _manufacturerController.text
          : null,
      model: _modelController.text.isNotEmpty ? _modelController.text : null,
      accessibility: _selectedAccessibility,
      installationType: _selectedInstallationType,
    );

    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _meterNumberController.clear();
      _serialNumberController.clear();
      _customerNameController.clear();
      _customerEmailController.clear();
      _customerPhoneController.clear();
      _wardController.clear();
      _manufacturerController.clear();
      _modelController.clear();
      _selectedStatuses.clear();
      _selectedTypes.clear();
      _selectedTechnologies.clear();
      _selectedConnectivity.clear();
      _selectedRegions.clear();
      _selectedAccessibility = null;
      _selectedInstallationType = null;
      _installedFrom = null;
      _installedTo = null;
    });
    widget.onClear();
  }

  Widget _buildMultiSelectChips<T>({
    required String title,
    required List<T> allItems,
    required List<T> selectedItems,
    required String Function(T) displayName,
    required Color Function(T) color,
    required Function(T, bool) onSelectionChanged,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allItems.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(
                    displayName(item),
                    style: TextStyle(
                      color: isSelected ? Colors.white : color(item),
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) => onSelectionChanged(item, selected),
                  backgroundColor: color(item).withValues(alpha: 0.1),
                  selectedColor: color(item),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: color(item).withValues(alpha: 0.3),
                    width: 1,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Installation Date Range',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _installedFrom ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _installedFrom = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _installedFrom != null
                                ? '${_installedFrom!.day}/${_installedFrom!.month}/${_installedFrom!.year}'
                                : 'Select date',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _installedTo ?? DateTime.now(),
                        firstDate: _installedFrom ?? DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _installedTo = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _installedTo != null
                                ? '${_installedTo!.day}/${_installedTo!.month}/${_installedTo!.year}'
                                : 'Select date',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Basic Search Fields
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _meterNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Meter Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _serialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Serial Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Status Filters
            _buildMultiSelectChips<MeterStatus>(
              title: 'Status',
              allItems: MeterStatus.values,
              selectedItems: _selectedStatuses,
              displayName: (status) => status.displayName,
              color: (status) => status.color,
              onSelectionChanged: (status, selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status);
                  } else {
                    _selectedStatuses.remove(status);
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Type Filters
            _buildMultiSelectChips<MeterType>(
              title: 'Meter Type',
              allItems: MeterType.values,
              selectedItems: _selectedTypes,
              displayName: (type) => type.displayName,
              color: (type) => Colors.blue,
              onSelectionChanged: (type, selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Technology Filters
            _buildMultiSelectChips<MeterTechnology>(
              title: 'Technology',
              allItems: MeterTechnology.values,
              selectedItems: _selectedTechnologies,
              displayName: (tech) => tech.displayName,
              color: (tech) => Colors.green,
              onSelectionChanged: (tech, selected) {
                setState(() {
                  if (selected) {
                    _selectedTechnologies.add(tech);
                  } else {
                    _selectedTechnologies.remove(tech);
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Connectivity Filters
            _buildMultiSelectChips<ConnectivityStatus>(
              title: 'Connectivity',
              allItems: ConnectivityStatus.values,
              selectedItems: _selectedConnectivity,
              displayName: (conn) => conn.displayName,
              color: (conn) => conn.color,
              onSelectionChanged: (conn, selected) {
                setState(() {
                  if (selected) {
                    _selectedConnectivity.add(conn);
                  } else {
                    _selectedConnectivity.remove(conn);
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Region Filters
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Regions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: NakuruServiceRegion.values.map((region) {
                        final isSelected = _selectedRegions.contains(region);
                        return FilterChip(
                          label: Text(
                            region.displayName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.purple,
                              fontSize: 11,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRegions.add(region);
                              } else {
                                _selectedRegions.remove(region);
                              }
                            });
                          },
                          backgroundColor: Colors.purple.withValues(alpha: 0.1),
                          selectedColor: Colors.purple,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Date Range
            _buildDateRangeSelector(),

            const SizedBox(height: 12),

            // Additional Filters
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _wardController,
                      decoration: const InputDecoration(
                        labelText: 'Ward',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Manufacturer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.factory, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.model_training, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedAccessibility,
                            decoration: const InputDecoration(
                              labelText: 'Accessibility',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.accessibility, size: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'easy', child: Text('Easy')),
                              DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                              DropdownMenuItem(value: 'difficult', child: Text('Difficult')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedAccessibility = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedInstallationType,
                            decoration: const InputDecoration(
                              labelText: 'Installation Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.place, size: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'indoor', child: Text('Indoor')),
                              DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
                              DropdownMenuItem(value: 'underground', child: Text('Underground')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedInstallationType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Clear All Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
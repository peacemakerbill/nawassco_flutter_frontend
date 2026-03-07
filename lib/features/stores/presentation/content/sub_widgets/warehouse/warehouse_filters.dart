import 'package:flutter/material.dart';
import '../../../../models/warehouse_model.dart';

class WarehouseFilters extends StatefulWidget {
  final ValueChanged<WarehouseStatus?> onStatusChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onClearFilters;

  const WarehouseFilters({
    super.key,
    required this.onStatusChanged,
    required this.onCityChanged,
    required this.onClearFilters,
  });

  @override
  State<WarehouseFilters> createState() => _WarehouseFiltersState();
}

class _WarehouseFiltersState extends State<WarehouseFilters> {
  WarehouseStatus? _selectedStatus;
  String? _selectedCity;

  final List<String> _cities = [
    'Nairobi',
    'Mombasa',
    'Kisumu',
    'Nakuru',
    'Eldoret',
    'Thika',
    'Malindi',
    'Kitale'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Status Filter
          const Text(
            'Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WarehouseStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(
                  _formatStatus(status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                  widget.onStatusChanged(_selectedStatus);
                },
                backgroundColor: theme.cardColor,
                selectedColor: theme.colorScheme.primary,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // City Filter
          const Text(
            'City',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              hintText: 'Select City',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (city) {
              setState(() {
                _selectedCity = city;
              });
              widget.onCityChanged(_selectedCity);
            },
          ),
          const SizedBox(height: 16),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedCity = null;
    });
    widget.onClearFilters();
  }

  String _formatStatus(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.OPERATIONAL:
        return 'Operational';
      case WarehouseStatus.UNDER_MAINTENANCE:
        return 'Maintenance';
      case WarehouseStatus.CLOSED:
        return 'Closed';
      case WarehouseStatus.UNDER_CONSTRUCTION:
        return 'Construction';
    }
  }
}
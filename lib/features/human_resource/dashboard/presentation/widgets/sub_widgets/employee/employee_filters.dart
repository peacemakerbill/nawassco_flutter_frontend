import 'package:flutter/material.dart';
import 'package:path/path.dart';

class EmployeeFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedDepartment;
  final String selectedStatus;
  final List<String> departments;
  final List<String> statuses;
  final Function(String) onSearchChanged;
  final Function(String) onDepartmentChanged;
  final Function(String) onStatusChanged;
  final VoidCallback onClearFilters;

  const EmployeeFilters({
    super.key,
    required this.searchController,
    required this.selectedDepartment,
    required this.selectedStatus,
    required this.departments,
    required this.statuses,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search employees...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                onSearchChanged('');
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),

        // Filters Row
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: selectedDepartment,
                items: departments,
                label: 'Department',
                onChanged: onDepartmentChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: selectedStatus,
                items: statuses,
                label: 'Status',
                onChanged: onStatusChanged,
              ),
            ),
            const SizedBox(width: 12),
            if (selectedDepartment != 'All' || selectedStatus != 'All' || searchController.text.isNotEmpty)
              IconButton(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                tooltip: 'Clear Filters',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context as BuildContext).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: Text(label),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) => onChanged(value!),
        ),
      ),
    );
  }
}